#[derive(Debug, Clone, PartialEq)]
pub enum Token {
    Identifier(String),
    Keyword(String),
    IntLiteral(i32),
    FloatLiteral(f32),
    StringLiteral(String),
    OpenParen,
    CloseParen,
    OpenBrace,
    CloseBrace,
    OpenBracket,
    CloseBracket,
    Semicolon,
    Comma,
    Dot,
    Colon,
    Plus,
    Minus,
    Star,
    Slash,
    Percent,
    Equals,
    EqualsEquals,
    NotEquals,
    LessThan,
    GreaterThan,
    LessEqual,
    GreaterEqual,
    And,
    Or,
    Not,
    Increment,
    Decrement,
    PlusEquals,
    MinusEquals,
    StarEquals,
    SlashEquals,
    Question,
    Hash,
    Newline,
    Whitespace,
    Comment(String),
    EOF,
}

impl Token {
    pub fn is_keyword(&self, kw: &str) -> bool {
        matches!(self, Token::Keyword(k) if k == kw)
    }

    pub fn is_binary_op(&self) -> bool {
        matches!(self,
            Token::Plus | Token::Minus | Token::Star | Token::Slash |
            Token::Percent | Token::EqualsEquals | Token::NotEquals |
            Token::LessThan | Token::GreaterThan | Token::LessEqual |
            Token::GreaterEqual | Token::And | Token::Or
        )
    }
}

static KEYWORDS: &[&str] = &[
    "int", "float", "string", "object", "void", "vector", "action",
    "struct", "talent", "effect", "itemproperty", "location", "json", "sqlquery",
    "if", "else", "switch", "case", "default", "break",
    "while", "for", "do", "continue", "return",
    "const", "extern", "static", "intelligent",
    "TRUE", "FALSE", "true", "false",
];

pub struct Lexer<'a> {
    input: &'a str,
    pos: usize,
    line: usize,
    col: usize,
}

impl<'a> Lexer<'a> {
    pub fn new(input: &'a str) -> Self {
        Self { input, pos: 0, line: 1, col: 1 }
    }

    fn peek(&self) -> Option<char> {
        self.input[self.pos..].chars().next()
    }

    fn advance(&mut self) -> Option<char> {
        let c = self.input[self.pos..].chars().next()?;
        self.pos += c.len_utf8();
        if c == '\n' {
            self.line += 1;
            self.col = 1;
        } else {
            self.col += 1;
        }
        Some(c)
    }

    pub fn tokenize(&mut self) -> Result<Vec<Token>, super::ScriptError> {
        let mut tokens = Vec::new();
        loop {
            match self.peek() {
                None => {
                    tokens.push(Token::EOF);
                    break;
                }
                Some(c) if c.is_whitespace() => {
                    self.advance();
                }
                Some('/') => {
                    let _start = self.pos;
                    self.advance();
                    if self.peek() == Some('/') {
                        self.advance();
                        let mut comment = String::new();
                        while let Some(ch) = self.peek() {
                            if ch == '\n' { break; }
                            comment.push(ch);
                            self.advance();
                        }
                        tokens.push(Token::Comment(comment));
                    } else if self.peek() == Some('*') {
                        self.advance();
                        let mut comment = String::new();
                        loop {
                            match self.advance() {
                                None => break,
                                Some('*') if self.peek() == Some('/') => {
                                    self.advance();
                                    break;
                                }
                                Some(c) => comment.push(c),
                            }
                        }
                        tokens.push(Token::Comment(comment));
                    } else {
                        tokens.push(Token::Slash);
                    }
                }
                Some('"') => {
                    self.advance();
                    let mut s = String::new();
                    loop {
                        match self.advance() {
                            None => break,
                            Some('"') => break,
                            Some('\\') => {
                                match self.advance() {
                                    Some('n') => s.push('\n'),
                                    Some('t') => s.push('\t'),
                                    Some('"') => s.push('"'),
                                    Some('\\') => s.push('\\'),
                                    Some(c) => s.push(c),
                                    None => s.push('\\'),
                                }
                            }
                            Some(c) => s.push(c),
                        }
                    }
                    tokens.push(Token::StringLiteral(s));
                }
                Some(c) if c.is_ascii_digit() => {
                    let mut num = String::new();
                    let mut is_float = false;
                    while let Some(ch) = self.peek() {
                        if ch.is_ascii_digit() { num.push(ch); self.advance(); }
                        else if ch == '.' {
                            if !is_float { is_float = true; num.push(ch); self.advance(); }
                            else { break; }
                        }
                        else { break; }
                    }
                    if is_float {
                        tokens.push(Token::FloatLiteral(num.parse::<f32>().unwrap_or(0.0)));
                    } else {
                        tokens.push(Token::IntLiteral(num.parse::<i32>().unwrap_or(0)));
                    }
                }
                Some(c) if c.is_ascii_alphabetic() || c == '_' => {
                    let mut ident = String::new();
                    while let Some(ch) = self.peek() {
                        if ch.is_alphanumeric() || ch == '_' { ident.push(ch); self.advance(); }
                        else { break; }
                    }
                    if KEYWORDS.contains(&ident.as_str()) {
                        tokens.push(Token::Keyword(ident));
                    } else {
                        tokens.push(Token::Identifier(ident));
                    }
                }
                Some(c) => {
                    self.advance();
                    let tok = match c {
                        '(' => Token::OpenParen,
                        ')' => Token::CloseParen,
                        '{' => Token::OpenBrace,
                        '}' => Token::CloseBrace,
                        '[' => Token::OpenBracket,
                        ']' => Token::CloseBracket,
                        ';' => Token::Semicolon,
                        ',' => Token::Comma,
                        '.' => Token::Dot,
                        '?' => Token::Question,
                        '#' => Token::Hash,
                        '+' => {
                            match self.peek() {
                                Some('+') => { self.advance(); Token::Increment }
                                Some('=') => { self.advance(); Token::PlusEquals }
                                _ => Token::Plus,
                            }
                        }
                        '-' => {
                            match self.peek() {
                                Some('-') => { self.advance(); Token::Decrement }
                                Some('=') => { self.advance(); Token::MinusEquals }
                                _ => Token::Minus,
                            }
                        }
                        '*' => {
                            if self.peek() == Some('=') { self.advance(); Token::StarEquals }
                            else { Token::Star }
                        }
                        '/' => {
                            if self.peek() == Some('=') { self.advance(); Token::SlashEquals }
                            else { Token::Slash }
                        }
                        '%' => Token::Percent,
                        '=' => {
                            if self.peek() == Some('=') { self.advance(); Token::EqualsEquals }
                            else { Token::Equals }
                        }
                        '!' => {
                            if self.peek() == Some('=') { self.advance(); Token::NotEquals }
                            else { Token::Not }
                        }
                        '<' => {
                            if self.peek() == Some('=') { self.advance(); Token::LessEqual }
                            else { Token::LessThan }
                        }
                        '>' => {
                            if self.peek() == Some('=') { self.advance(); Token::GreaterEqual }
                            else { Token::GreaterThan }
                        }
                        '&' => {
                            if self.peek() == Some('&') { self.advance(); Token::And }
                            else { return Err(super::ScriptError::Lexer { line: self.line, col: self.col - 1, msg: "expected &&".into() }); }
                        }
                        '|' => {
                            if self.peek() == Some('|') { self.advance(); Token::Or }
                            else { return Err(super::ScriptError::Lexer { line: self.line, col: self.col - 1, msg: "expected ||".into() }); }
                        }
                        ':' => Token::Colon,
                        '\n' => Token::Newline,
                        _ => return Err(super::ScriptError::Lexer {
                            line: self.line,
                            col: self.col - 1,
                            msg: format!("unexpected character '{}'", c),
                        }),
                    };
                    tokens.push(tok);
                }
            }
        }
        Ok(tokens)
    }
}
