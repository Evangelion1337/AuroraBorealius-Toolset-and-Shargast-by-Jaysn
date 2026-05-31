use crate::lexer::Token;
use crate::ast::*;

pub struct Parser {
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self { tokens, pos: 0 }
    }

    fn peek(&self) -> Option<&Token> {
        self.tokens.get(self.pos)
    }

    fn advance(&mut self) -> Option<&Token> {
        let tok = self.tokens.get(self.pos)?;
        self.pos += 1;
        Some(tok)
    }

    fn expect(&mut self, expected: &Token) -> Result<(), super::ScriptError> {
        if let Some(tok) = self.peek() {
            if std::mem::discriminant(tok) == std::mem::discriminant(expected) {
                self.advance();
                Ok(())
            } else {
                Err(super::ScriptError::Parser {
                    line: 0, col: 0,
                    msg: format!("expected {:?}, got {:?}", expected, tok),
                })
            }
        } else {
            Err(super::ScriptError::Parser {
                line: 0, col: 0,
                msg: format!("expected {:?}, got EOF", expected),
            })
        }
    }

    pub fn parse(&mut self) -> Result<Program, super::ScriptError> {
        let mut statements = Vec::new();
        while !matches!(self.peek(), None | Some(Token::EOF)) {
            statements.push(self.parse_statement()?);
        }
        Ok(Program { statements })
    }

    fn parse_statement(&mut self) -> Result<Statement, super::ScriptError> {
        match self.peek() {
            Some(Token::Keyword(kw)) if kw == "int" || kw == "float" || kw == "string"
                || kw == "object" || kw == "void" || kw == "vector" || kw == "action"
                || kw == "struct" || kw == "talent" || kw == "effect" || kw == "itemproperty"
                || kw == "location" || kw == "json" || kw == "sqlquery" => {
                self.parse_var_or_func_decl()
            }
            Some(Token::Keyword(kw)) if kw == "if" => self.parse_if(),
            Some(Token::Keyword(kw)) if kw == "while" => self.parse_while(),
            Some(Token::Keyword(kw)) if kw == "for" => self.parse_for(),
            Some(Token::Keyword(kw)) if kw == "do" => self.parse_do_while(),
            Some(Token::Keyword(kw)) if kw == "switch" => self.parse_switch(),
            Some(Token::Keyword(kw)) if kw == "return" => self.parse_return(),
            Some(Token::Keyword(kw)) if kw == "break" => { self.advance(); Ok(Statement::Break) }
            Some(Token::Keyword(kw)) if kw == "continue" => { self.advance(); Ok(Statement::Continue) }
            Some(Token::OpenBrace) => self.parse_block(),
            _ => self.parse_expr_statement(),
        }
    }

    fn parse_var_or_func_decl(&mut self) -> Result<Statement, super::ScriptError> {
        let type_name = match self.advance() {
            Some(Token::Keyword(kw)) => kw.clone(),
            _ => return Err(super::ScriptError::Parser { line: 0, col: 0, msg: "expected type keyword".into() }),
        };
        let name = match self.advance() {
            Some(Token::Identifier(id)) => id.clone(),
            _ => return Err(super::ScriptError::Parser { line: 0, col: 0, msg: "expected identifier".into() }),
        };
        if self.peek() == Some(&Token::OpenParen) {
            let params = self.parse_params()?;
            if self.peek() == Some(&Token::Semicolon) {
                self.advance();
                Ok(Statement::FunctionDecl(FunctionDecl {
                    return_type: type_name,
                    name,
                    params,
                    body: None,
                }))
            } else {
                self.expect(&Token::OpenBrace)?;
                let body = self.parse_block_inner()?;
                Ok(Statement::FunctionDecl(FunctionDecl {
                    return_type: type_name,
                    name,
                    params,
                    body: Some(body),
                }))
            }
        } else {
            let mut expr = Expression::Identifier(name);
            if self.peek() == Some(&Token::Equals) {
                self.advance();
                let init = self.parse_expression(0)?;
                expr = Expression::Assign(Box::new(expr), Box::new(init));
            }
            self.expect(&Token::Semicolon)?;
            Ok(Statement::VarDecl(VarDecl {
                type_name,
                name: String::new(),
                initializer: Some(expr),
            }))
        }
    }

    fn parse_params(&mut self) -> Result<Vec<Param>, super::ScriptError> {
        self.expect(&Token::OpenParen)?;
        let mut params = Vec::new();
        while !matches!(self.peek(), Some(Token::CloseParen) | None) {
            let type_name = match self.advance() {
                Some(Token::Keyword(kw)) => kw.clone(),
                _ => return Err(super::ScriptError::Parser { line: 0, col: 0, msg: "expected type".into() }),
            };
            let name = match self.advance() {
                Some(Token::Identifier(id)) => id.clone(),
                _ => return Err(super::ScriptError::Parser { line: 0, col: 0, msg: "expected param name".into() }),
            };
            params.push(Param { type_name, name });
            if self.peek() == Some(&Token::Comma) { self.advance(); }
        }
        self.expect(&Token::CloseParen)?;
        Ok(params)
    }

    fn parse_if(&mut self) -> Result<Statement, super::ScriptError> {
        self.advance();
        self.expect(&Token::OpenParen)?;
        let condition = self.parse_expression(0)?;
        self.expect(&Token::CloseParen)?;
        let then_branch = Box::new(self.parse_statement()?);
        let else_branch = if self.peek() == Some(&Token::Keyword("else".to_string())) {
            self.advance();
            Some(Box::new(self.parse_statement()?))
        } else { None };
        Ok(Statement::If(condition, then_branch, else_branch))
    }

    fn parse_while(&mut self) -> Result<Statement, super::ScriptError> {
        self.advance();
        self.expect(&Token::OpenParen)?;
        let condition = self.parse_expression(0)?;
        self.expect(&Token::CloseParen)?;
        let body = Box::new(self.parse_statement()?);
        Ok(Statement::While(condition, body))
    }

    fn parse_for(&mut self) -> Result<Statement, super::ScriptError> {
        self.advance();
        self.expect(&Token::OpenParen)?;
        let init = if self.peek() != Some(&Token::Semicolon) {
            Some(Box::new(self.parse_statement()?))
        } else { None };
        self.expect(&Token::Semicolon)?;
        let condition = if self.peek() != Some(&Token::Semicolon) {
            Some(self.parse_expression(0)?)
        } else { None };
        self.expect(&Token::Semicolon)?;
        let update = if self.peek() != Some(&Token::CloseParen) {
            Some(self.parse_expression(0)?)
        } else { None };
        self.expect(&Token::CloseParen)?;
        let body = Box::new(self.parse_statement()?);
        Ok(Statement::For(init, condition, update, body))
    }

    fn parse_do_while(&mut self) -> Result<Statement, super::ScriptError> {
        self.advance();
        let body = Box::new(self.parse_statement()?);
        self.expect(&Token::Keyword("while".to_string()))?;
        self.expect(&Token::OpenParen)?;
        let condition = self.parse_expression(0)?;
        self.expect(&Token::CloseParen)?;
        self.expect(&Token::Semicolon)?;
        Ok(Statement::DoWhile(condition, body))
    }

    fn parse_switch(&mut self) -> Result<Statement, super::ScriptError> {
        self.advance();
        self.expect(&Token::OpenParen)?;
        let value = self.parse_expression(0)?;
        self.expect(&Token::CloseParen)?;
        self.expect(&Token::OpenBrace)?;
        let mut cases = Vec::new();
        let mut default_case: Option<Vec<Statement>> = None;
        while !matches!(self.peek(), Some(Token::CloseBrace) | None) {
            if self.peek() == Some(&Token::Keyword("case".to_string())) {
                self.advance();
                let val = self.parse_expression(0)?;
                self.expect(&Token::Colon)?;
                let mut body = Vec::new();
                while !matches!(self.peek(), Some(Token::Keyword(k)) if k == "case" || k == "default"
                    || matches!(self.peek(), Some(Token::CloseBrace))) {
                    body.push(self.parse_statement()?);
                }
                cases.push((val, body));
            } else if self.peek() == Some(&Token::Keyword("default".to_string())) {
                self.advance();
                self.expect(&Token::Colon)?;
                let mut body = Vec::new();
                while !matches!(self.peek(), Some(Token::CloseBrace)) {
                    body.push(self.parse_statement()?);
                }
                default_case = Some(body);
            }
        }
        self.expect(&Token::CloseBrace)?;
        Ok(Statement::Switch(value, cases, default_case))
    }

    fn parse_return(&mut self) -> Result<Statement, super::ScriptError> {
        self.advance();
        let value = if self.peek() != Some(&Token::Semicolon) {
            Some(self.parse_expression(0)?)
        } else { None };
        self.expect(&Token::Semicolon)?;
        Ok(Statement::Return(value))
    }

    fn parse_block(&mut self) -> Result<Statement, super::ScriptError> {
        self.expect(&Token::OpenBrace)?;
        let statements = self.parse_block_inner()?;
        Ok(Statement::Block(statements))
    }

    fn parse_block_inner(&mut self) -> Result<Vec<Statement>, super::ScriptError> {
        let mut statements = Vec::new();
        while !matches!(self.peek(), Some(Token::CloseBrace) | None | Some(Token::EOF)) {
            statements.push(self.parse_statement()?);
        }
        self.expect(&Token::CloseBrace)?;
        Ok(statements)
    }

    fn parse_expr_statement(&mut self) -> Result<Statement, super::ScriptError> {
        let expr = self.parse_expression(0)?;
        if self.peek() == Some(&Token::Semicolon) {
            self.advance();
        }
        Ok(Statement::Expr(expr))
    }

    fn parse_expression(&mut self, min_prec: u32) -> Result<Expression, super::ScriptError> {
        let mut lhs = self.parse_primary()?;

        while let Some(tok) = self.peek() {
            let prec = match tok {
                Token::Equals | Token::PlusEquals | Token::MinusEquals |
                Token::StarEquals | Token::SlashEquals => 1,
                Token::Or => 2,
                Token::And => 3,
                Token::EqualsEquals | Token::NotEquals => 4,
                Token::LessThan | Token::GreaterThan | Token::LessEqual | Token::GreaterEqual => 5,
                Token::Plus | Token::Minus => 6,
                Token::Star | Token::Slash | Token::Percent => 7,
                _ => break,
            };
            if prec <= min_prec { break; }
            let op = self.advance().ok_or_else(|| super::ScriptError::Parser { line: 0, col: 0, msg: "expected operator token".into() })?.clone();
            let rhs = self.parse_expression(prec + 1)?;
            lhs = Expression::BinaryOp(Box::new(lhs), op, Box::new(rhs));
        }
        Ok(lhs)
    }

    fn parse_primary(&mut self) -> Result<Expression, super::ScriptError> {
        match self.peek() {
            Some(Token::IntLiteral(n)) => {
                let val = *n; self.advance();
                Ok(Expression::IntLiteral(val))
            }
            Some(Token::FloatLiteral(f)) => {
                let val = *f; self.advance();
                Ok(Expression::FloatLiteral(val))
            }
            Some(Token::StringLiteral(s)) => {
                let val = s.clone(); self.advance();
                Ok(Expression::StringLiteral(val))
            }
            Some(Token::Identifier(id)) => {
                let name = id.clone(); self.advance();
                if self.peek() == Some(&Token::OpenParen) {
                    let args = self.parse_call_args()?;
                    Ok(Expression::Call(name, args))
                } else if self.peek() == Some(&Token::Increment) {
                    self.advance();
                    Ok(Expression::UnaryOp(Token::Increment, Box::new(Expression::Identifier(name))))
                } else if self.peek() == Some(&Token::Decrement) {
                    self.advance();
                    Ok(Expression::UnaryOp(Token::Decrement, Box::new(Expression::Identifier(name))))
                } else {
                    Ok(Expression::Identifier(name))
                }
            }
            Some(Token::Not) => {
                self.advance();
                let expr = self.parse_primary()?;
                Ok(Expression::UnaryOp(Token::Not, Box::new(expr)))
            }
            Some(Token::Minus) => {
                self.advance();
                let expr = self.parse_primary()?;
                Ok(Expression::UnaryOp(Token::Minus, Box::new(expr)))
            }
            Some(Token::Increment) => {
                self.advance();
                let expr = self.parse_primary()?;
                Ok(Expression::UnaryOp(Token::Increment, Box::new(expr)))
            }
            Some(Token::Decrement) => {
                self.advance();
                let expr = self.parse_primary()?;
                Ok(Expression::UnaryOp(Token::Decrement, Box::new(expr)))
            }
            Some(Token::OpenParen) => {
                self.advance();
                let expr = self.parse_expression(0)?;
                self.expect(&Token::CloseParen)?;
                Ok(expr)
            }
            Some(Token::Keyword(kw)) if kw == "TRUE" || kw == "true" => {
                self.advance();
                Ok(Expression::IntLiteral(1))
            }
            Some(Token::Keyword(kw)) if kw == "FALSE" || kw == "false" => {
                self.advance();
                Ok(Expression::IntLiteral(0))
            }
            _ => Err(super::ScriptError::Parser {
                line: 0, col: 0,
                msg: format!("unexpected token: {:?}", self.peek()),
            }),
        }
    }

    fn parse_call_args(&mut self) -> Result<Vec<Expression>, super::ScriptError> {
        self.expect(&Token::OpenParen)?;
        let mut args = Vec::new();
        while !matches!(self.peek(), Some(Token::CloseParen) | None | Some(Token::EOF)) {
            args.push(self.parse_expression(0)?);
            if self.peek() == Some(&Token::Comma) { self.advance(); }
        }
        self.expect(&Token::CloseParen)?;
        Ok(args)
    }
}
