#[derive(Debug, Clone)]
pub struct Program {
    pub statements: Vec<Statement>,
}

#[derive(Debug, Clone)]
pub enum Statement {
    VarDecl(VarDecl),
    FunctionDecl(FunctionDecl),
    Block(Vec<Statement>),
    Expr(Expression),
    If(Expression, Box<Statement>, Option<Box<Statement>>),
    While(Expression, Box<Statement>),
    For(Option<Box<Statement>>, Option<Expression>, Option<Expression>, Box<Statement>),
    DoWhile(Expression, Box<Statement>),
    Switch(Expression, Vec<(Expression, Vec<Statement>)>, Option<Vec<Statement>>),
    Return(Option<Expression>),
    Break,
    Continue,
}

#[derive(Debug, Clone)]
pub struct VarDecl {
    pub type_name: String,
    pub name: String,
    pub initializer: Option<Expression>,
}

#[derive(Debug, Clone)]
pub struct FunctionDecl {
    pub return_type: String,
    pub name: String,
    pub params: Vec<Param>,
    pub body: Option<Vec<Statement>>,
}

#[derive(Debug, Clone)]
pub struct Param {
    pub type_name: String,
    pub name: String,
}

#[derive(Debug, Clone)]
pub enum Expression {
    IntLiteral(i32),
    FloatLiteral(f32),
    StringLiteral(String),
    Identifier(String),
    Call(String, Vec<Expression>),
    BinaryOp(Box<Expression>, crate::lexer::Token, Box<Expression>),
    UnaryOp(crate::lexer::Token, Box<Expression>),
    Assign(Box<Expression>, Box<Expression>),
}
