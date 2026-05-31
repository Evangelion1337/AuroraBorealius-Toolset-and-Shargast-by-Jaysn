use std::collections::HashMap;
use crate::ast::*;
use crate::lexer::Token;

const OP_CPDOWNSP: u8 = 0x01;
const OP_RSADD: u8 = 0x02;
const OP_CPTOPSP: u8 = 0x03;
const OP_CONST: u8 = 0x04;
const OP_ACTION: u8 = 0x05;
const OP_LOGAND: u8 = 0x06;
const OP_LOGOR: u8 = 0x07;
const OP_EQ: u8 = 0x0B;
const OP_NEQ: u8 = 0x0C;
const OP_GEQ: u8 = 0x0D;
const OP_GT: u8 = 0x0E;
const OP_LT: u8 = 0x0F;
const OP_LEQ: u8 = 0x10;
const OP_ADD: u8 = 0x14;
const OP_SUB: u8 = 0x15;
const OP_MUL: u8 = 0x16;
const OP_DIV: u8 = 0x17;
const OP_MOD: u8 = 0x18;
const OP_NEG: u8 = 0x19;
const OP_MOVSP: u8 = 0x1B;
const OP_JMP: u8 = 0x1D;
const OP_JSR: u8 = 0x1E;
const OP_JZ: u8 = 0x1F;
const OP_JNZ: u8 = 0x25;
const OP_RETN: u8 = 0x20;
const OP_NOT: u8 = 0x22;
const OP_SAVEBP: u8 = 0x2A;
const OP_RESTOREBP: u8 = 0x2B;

const TYPE_NONE: u8 = 0x00;
const TYPE_DIRECT: u8 = 0x01;
const TYPE_INT: u8 = 0x03;
const TYPE_FLOAT: u8 = 0x04;
const TYPE_STRING: u8 = 0x05;
const TYPE_OBJECT: u8 = 0x06;
const TYPE_INT_INT: u8 = 0x20;

pub struct Compiler {
    out: Vec<u8>,
    labels: HashMap<String, u32>,
    pending: Vec<PendingJump>,
    local_count: u32,
    local_names: HashMap<String, u32>,
    function_info: HashMap<String, FunctionInfo>,
    errors: Vec<String>,
    next_label_id: u32,
}

#[derive(Clone)]
struct FunctionInfo {
    entry: u32,
    param_count: usize,
}

struct PendingJump {
    pos: usize,
    label: String,
}

impl Compiler {
    pub fn new() -> Self {
        Self {
            out: Vec::new(),
            labels: HashMap::new(),
            pending: Vec::new(),
            local_count: 0,
            local_names: HashMap::new(),
            function_info: HashMap::new(),
            errors: Vec::new(),
            next_label_id: 0,
        }
    }

    fn fresh_label(&mut self) -> String {
        let id = self.next_label_id;
        self.next_label_id += 1;
        format!(".L{}", id)
    }

    fn err(&mut self, msg: String) {
        self.errors.push(msg);
    }

    fn write_u8(&mut self, v: u8) { self.out.push(v); }

    fn write_u16(&mut self, v: u16) {
        self.out.extend_from_slice(&v.to_be_bytes());
    }

    fn write_i32(&mut self, v: i32) {
        self.out.extend_from_slice(&v.to_be_bytes());
    }

    fn write_i16(&mut self, v: i16) {
        self.out.extend_from_slice(&v.to_be_bytes());
    }

    fn write_bytes(&mut self, bytes: &[u8]) {
        self.out.extend_from_slice(bytes);
    }

    fn define_label(&mut self, name: &str) {
        self.labels.insert(name.to_string(), self.out.len() as u32);
    }

    fn emit_label(&mut self, name: &str) {
        self.define_label(name);
    }

    fn emit_jmp(&mut self, label: &str) {
        let pos = self.out.len();
        self.write_u8(OP_JMP);
        self.write_u8(TYPE_NONE);
        self.write_i32(0);
        self.pending.push(PendingJump { pos, label: label.to_string() });
    }

    fn emit_jz(&mut self, label: &str) {
        let pos = self.out.len();
        self.write_u8(OP_JZ);
        self.write_u8(TYPE_NONE);
        self.write_i32(0);
        self.pending.push(PendingJump { pos, label: label.to_string() });
    }

    fn emit_jnz(&mut self, label: &str) {
        let pos = self.out.len();
        self.write_u8(OP_JNZ);
        self.write_u8(TYPE_NONE);
        self.write_i32(0);
        self.pending.push(PendingJump { pos, label: label.to_string() });
    }

    fn emit_rsadd(&mut self, typ: u8) {
        self.write_u8(OP_RSADD);
        self.write_u8(typ);
    }

    fn emit_const_int(&mut self, val: i32) {
        self.write_u8(OP_CONST);
        self.write_u8(TYPE_INT);
        self.write_i32(val);
    }

    fn emit_const_float(&mut self, val: f32) {
        self.write_u8(OP_CONST);
        self.write_u8(TYPE_FLOAT);
        self.write_bytes(&val.to_bits().to_be_bytes());
    }

    fn emit_const_string(&mut self, val: &str) {
        self.write_u8(OP_CONST);
        self.write_u8(TYPE_STRING);
        self.write_u16(val.len() as u16);
        self.write_bytes(val.as_bytes());
    }

    fn emit_cptopsp(&mut self, offset: i32, size: i16) {
        self.write_u8(OP_CPTOPSP);
        self.write_u8(TYPE_DIRECT);
        self.write_i32(offset);
        self.write_i16(size);
    }

    fn emit_cpdownsp(&mut self, offset: i32, size: i16) {
        self.write_u8(OP_CPDOWNSP);
        self.write_u8(TYPE_DIRECT);
        self.write_i32(offset);
        self.write_i16(size);
    }

    fn emit_movsp(&mut self, val: i32) {
        self.write_u8(OP_MOVSP);
        self.write_u8(TYPE_NONE);
        self.write_i32(val);
    }

    fn alloc_local(&mut self, name: &str, typ: &str) -> u32 {
        let idx = self.local_count;
        self.local_count += 1;
        self.local_names.insert(name.to_string(), idx);
        let type_byte = type_to_rsadd(typ);
        self.emit_rsadd(type_byte);
        idx
    }

    fn local_offset(&self, idx: u32) -> i32 {
        -((idx + 1) as i32 * 4)
    }

    pub fn compile(&mut self, program: &Program) -> Vec<u8> {
        self.out.clear();
        self.labels.clear();
        self.pending.clear();
        self.local_count = 0;
        self.local_names.clear();
        self.function_info.clear();
        self.errors.clear();

        self.compile_program(program);

        let body = std::mem::take(&mut self.out);
        let total_len = 13 + body.len();
        let mut ncs = Vec::with_capacity(total_len);
        ncs.extend_from_slice(b"NCS V1.0");
        ncs.push(0x42);
        ncs.extend_from_slice(&(total_len as u32).to_be_bytes());
        ncs.extend_from_slice(&body);
        ncs
    }

    fn compile_program(&mut self, prog: &Program) {
        for stmt in &prog.statements {
            self.compile_statement(stmt);
        }
    }

    fn compile_statement(&mut self, stmt: &Statement) {
        match stmt {
            Statement::FunctionDecl(fd) => self.compile_function(fd),
            Statement::VarDecl(vd) => {
                let (name, init) = resolve_vardecl(vd);
                if name.is_empty() { return; }
                self.alloc_local(&name, &vd.type_name);
                if let Some(expr) = init {
                    self.compile_expression(&expr);
                    let idx = self.local_count - 1;
                    let off = self.local_offset(idx);
                    self.emit_cpdownsp(off, 4);
                    self.emit_movsp(-4);
                }
            }
            Statement::Block(stmts) => {
                let saved = self.local_count;
                for s in stmts {
                    self.compile_statement(s);
                }
                let popped = self.local_count - saved;
                if popped > 0 {
                    self.emit_movsp(-(popped as i32 * 4));
                }
                self.local_count = saved;
            }
            Statement::Expr(expr) => {
                self.compile_expression(expr);
                self.emit_movsp(-4);
            }
            Statement::If(cond, then_branch, else_branch) => {
                let else_label = self.fresh_label();
                let end_label = self.fresh_label();
                self.compile_expression(cond);
                self.emit_jz(&else_label);
                self.compile_statement(then_branch);
                self.emit_jmp(&end_label);
                self.emit_label(&else_label);
                if let Some(else_stmt) = else_branch {
                    self.compile_statement(else_stmt);
                }
                self.emit_label(&end_label);
            }
            Statement::While(cond, body) => {
                let loop_label = self.fresh_label();
                let end_label = self.fresh_label();
                self.emit_label(&loop_label);
                self.compile_expression(cond);
                self.emit_jz(&end_label);
                self.compile_statement(body);
                self.emit_jmp(&loop_label);
                self.emit_label(&end_label);
            }
            Statement::For(init, cond, update, body) => {
                let saved = self.local_count;
                if let Some(init_stmt) = init {
                    self.compile_statement(init_stmt);
                }
                let loop_label = self.fresh_label();
                let end_label = self.fresh_label();
                self.emit_label(&loop_label);
                if let Some(c) = cond {
                    self.compile_expression(c);
                    self.emit_jz(&end_label);
                }
                self.compile_statement(body);
                if let Some(u) = update {
                    self.compile_expression(u);
                    self.emit_movsp(-4);
                }
                self.emit_jmp(&loop_label);
                self.emit_label(&end_label);
                let popped = self.local_count - saved;
                if popped > 0 {
                    self.emit_movsp(-(popped as i32 * 4));
                }
                self.local_count = saved;
            }
            Statement::DoWhile(cond, body) => {
                let loop_label = self.fresh_label();
                let end_label = self.fresh_label();
                self.emit_label(&loop_label);
                self.compile_statement(body);
                self.compile_expression(cond);
                self.emit_jnz(&loop_label);
                self.emit_label(&end_label);
            }
            Statement::Switch(val, cases, default) => {
                let end_label = self.fresh_label();
                let mut case_labels: Vec<String> = Vec::new();
                for _ in cases {
                    case_labels.push(self.fresh_label());
                }
                let default_label = self.fresh_label();
                self.compile_expression(val);
                for (i, (case_val, _stmts)) in cases.iter().enumerate() {
                    self.emit_cptopsp(-4, 4);
                    self.compile_expression(case_val);
                    self.write_u8(OP_EQ);
                    self.write_u8(TYPE_INT_INT);
                    self.emit_jnz(&case_labels[i]);
                }
                self.emit_jmp(&default_label);
                for (i, (_case_val, stmts)) in cases.iter().enumerate() {
                    self.emit_label(&case_labels[i]);
                    for s in stmts {
                        self.compile_statement(s);
                    }
                    self.emit_jmp(&end_label);
                }
                self.emit_label(&default_label);
                if let Some(d) = default {
                    for s in d {
                        self.compile_statement(s);
                    }
                }
                self.emit_label(&end_label);
                self.emit_movsp(-4);
            }
            Statement::Return(expr) => {
                if let Some(e) = expr {
                    self.compile_expression(e);
                }
                if self.local_count > 0 {
                    self.emit_movsp(-(self.local_count as i32 * 4));
                }
                self.write_u8(OP_RETN);
                self.write_u8(TYPE_NONE);
            }
            Statement::Break | Statement::Continue => {
                self.err("break/continue not supported at top level".to_string());
            }
        }
    }

    fn compile_function(&mut self, fd: &FunctionDecl) {
        let saved_local_count = self.local_count;
        let saved_local_names = self.local_names.clone();

        self.local_count = 0;
        self.local_names.clear();

        let entry = self.out.len() as u32;

        self.write_u8(OP_SAVEBP);
        self.write_u8(TYPE_NONE);

        for param in &fd.params {
            let idx = self.alloc_local(&param.name, &param.type_name);
            let off = self.local_offset(idx);
            if idx == 0 {
                self.emit_cptopsp(-4, 4);
            } else {
                self.emit_cptopsp(off + 4, 4);
            }
            self.emit_cpdownsp(off, 4);
            self.emit_movsp(-4);
        }

        if let Some(body) = &fd.body {
            for stmt in body {
                self.compile_statement(stmt);
            }
        }

        if self.local_count > 0 {
            self.emit_movsp(-(self.local_count as i32 * 4));
        }
        self.write_u8(OP_RESTOREBP);
        self.write_u8(TYPE_NONE);
        self.write_u8(OP_RETN);
        self.write_u8(TYPE_NONE);

        self.function_info.insert(fd.name.clone(), FunctionInfo {
            entry,
            param_count: fd.params.len(),
        });

        self.local_count = saved_local_count;
        self.local_names = saved_local_names;
    }

    fn compile_expression(&mut self, expr: &Expression) {
        match expr {
            Expression::IntLiteral(n) => self.emit_const_int(*n),
            Expression::FloatLiteral(f) => self.emit_const_float(*f),
            Expression::StringLiteral(s) => self.emit_const_string(s),
            Expression::Identifier(name) => {
                if let Some(&idx) = self.local_names.get(name) {
                    let off = self.local_offset(idx);
                    self.emit_cptopsp(off, 4);
                } else if let Some(_fi) = self.function_info.get(name) {
                    self.err(format!("Cannot use function '{}' as variable", name));
                } else {
                    self.err(format!("Undefined variable '{}'", name));
                }
            }
            Expression::Call(name, args) => {
                let user_func = self.function_info.get(name).cloned();
                if let Some(fi) = user_func {
                    if args.len() != fi.param_count {
                        self.err(format!("Function '{}' expects {} args, got {}", name, fi.param_count, args.len()));
                        return;
                    }
                    for arg in args {
                        self.compile_expression(arg);
                    }
                    let rel_offset = (fi.entry as i32) - (self.out.len() as i32 + 6);
                    self.write_u8(OP_JSR);
                    self.write_u8(TYPE_NONE);
                    self.write_i32(rel_offset);
                } else {
                    for arg in args {
                        self.compile_expression(arg);
                    }
                    let func_id = resolve_engine_function(name);
                    self.write_u8(OP_ACTION);
                    self.write_u8(TYPE_NONE);
                    self.write_u16(func_id);
                    self.write_u8(args.len() as u8);
                }
            }
            Expression::BinaryOp(lhs, op, rhs) => {
                match op {
                    Token::And => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_LOGAND);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::Or => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_LOGOR);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::EqualsEquals => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_EQ);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::NotEquals => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_NEQ);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::LessThan => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_LT);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::GreaterThan => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_GT);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::LessEqual => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_LEQ);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::GreaterEqual => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_GEQ);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::Plus => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_ADD);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::Minus => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_SUB);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::Star => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_MUL);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::Slash => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_DIV);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::Percent => {
                        self.compile_expression(lhs);
                        self.compile_expression(rhs);
                        self.write_u8(OP_MOD);
                        self.write_u8(TYPE_INT_INT);
                    }
                    Token::Equals | Token::PlusEquals | Token::MinusEquals | Token::StarEquals | Token::SlashEquals => {
                        if let Expression::Identifier(var_name) = lhs.as_ref() {
                            if let Some(&idx) = self.local_names.get(var_name) {
                                let off = self.local_offset(idx);
                                match op {
                                    Token::Equals => {
                                        self.compile_expression(rhs);
                                        self.emit_cpdownsp(off, 4);
                                        self.emit_movsp(-4);
                                    }
                                    Token::PlusEquals => {
                                        self.emit_cptopsp(off, 4);
                                        self.compile_expression(rhs);
                                        self.write_u8(OP_ADD);
                                        self.write_u8(TYPE_INT_INT);
                                        self.emit_cpdownsp(off, 4);
                                        self.emit_movsp(-4);
                                    }
                                    _ => {
                                        self.emit_cptopsp(off, 4);
                                        self.compile_expression(rhs);
                                        let binop = match op {
                                            Token::MinusEquals => OP_SUB,
                                            Token::StarEquals => OP_MUL,
                                            Token::SlashEquals => OP_DIV,
                                            _ => OP_SUB,
                                        };
                                        self.write_u8(binop);
                                        self.write_u8(TYPE_INT_INT);
                                        self.emit_cpdownsp(off, 4);
                                        self.emit_movsp(-4);
                                    }
                                }
                            } else {
                                self.err(format!("Undefined variable '{}' for assignment", var_name));
                            }
                        } else {
                            self.err(format!("Cannot assign to non-variable"));
                        }
                    }
                    _ => {
                        self.err(format!("Unsupported binary operator: {:?}", op));
                    }
                }
            }
            Expression::UnaryOp(op, expr) => {
                match op {
                    Token::Minus => {
                        self.compile_expression(expr);
                        self.write_u8(OP_NEG);
                        self.write_u8(TYPE_INT);
                    }
                    Token::Not => {
                        self.compile_expression(expr);
                        self.write_u8(OP_NOT);
                        self.write_u8(TYPE_INT);
                    }
                    _ => {
                        self.err(format!("Unsupported unary operator: {:?}", op));
                    }
                }
            }
            Expression::Assign(lhs, rhs) => {
                if let Expression::Identifier(var_name) = lhs.as_ref() {
                    if let Some(&idx) = self.local_names.get(var_name) {
                        let off = self.local_offset(idx);
                        self.compile_expression(rhs);
                        self.emit_cpdownsp(off, 4);
                        self.emit_movsp(-4);
                    } else {
                        self.err(format!("Undefined variable '{}'", var_name));
                    }
                } else {
                    self.err(format!("Cannot assign to non-variable"));
                }
            }
        }
    }

    pub fn finalize(&mut self) -> Result<(), Vec<String>> {
        if !self.errors.is_empty() {
            return Err(std::mem::take(&mut self.errors));
        }
        let mut unresolved = Vec::new();
        for pj in &self.pending {
            let target = match self.labels.get(&pj.label) {
                Some(off) => *off as i32,
                None => {
                    unresolved.push(pj.label.clone());
                    continue;
                }
            };
            let insn_start = pj.pos;
            let rel = target - insn_start as i32;
            self.out[pj.pos + 2..pj.pos + 6].copy_from_slice(&rel.to_be_bytes());
        }
        if !unresolved.is_empty() {
            return Err(unresolved);
        }
        Ok(())
    }
}

fn type_to_rsadd(typ: &str) -> u8 {
    match typ {
        "int" => TYPE_INT,
        "float" => TYPE_FLOAT,
        "string" => TYPE_STRING,
        "object" => TYPE_OBJECT,
        _ => TYPE_INT,
    }
}

fn resolve_vardecl(vd: &VarDecl) -> (String, Option<Expression>) {
    match &vd.initializer {
        Some(Expression::Assign(lhs, rhs)) => {
            if let Expression::Identifier(name) = lhs.as_ref() {
                (name.clone(), Some(rhs.as_ref().clone()))
            } else {
                (vd.name.clone(), None)
            }
        }
        Some(Expression::Identifier(name)) => {
            (name.clone(), None)
        }
        Some(expr) => (vd.name.clone(), Some(expr.clone())),
        None => (vd.name.clone(), None),
    }
}

fn resolve_engine_function(name: &str) -> u16 {
    match name {
        "PrintString" => 0,
        "SendMessageToPC" => 369,
        "PrintInteger" => 2,
        "PrintFloat" => 3,
        "FloatToString" => 4,
        "IntToString" => 5,
        "StringToInt" => 109,
        "StringToFloat" => 110,
        "IntToFloat" => 23,
        "FloatToInt" => 24,
        "GetStringLength" => 113,
        "GetStringUpperCase" => 119,
        "GetStringLowerCase" => 120,
        "IntToStringByStrRef" => 497,
        "WriteTimestampedLogEntry" => 537,
        "SpeakString" => 522,
        "SpeakOneLinerConversation" => 481,
        "GetJournalEntry" => 116,
        "AddJournalQuestEntry" => 200,
        "RemoveJournalQuestEntry" => 201,
        "GetName" => 425,
        "GetTag" => 426,
        "GetLocalString" => 170,
        "GetLocalInt" => 171,
        "GetLocalFloat" => 172,
        "SetLocalString" => 173,
        "SetLocalInt" => 174,
        "SetLocalFloat" => 175,
        "GetObjectType" => 427,
        "GetPosition" => 430,
        "GetFacing" => 431,
        "GetFirstObjectInShape" => 319,
        "GetNextObjectInShape" => 320,
        "GetNearestCreature" => 321,
        "GetFirstPC" => 371,
        "GetNextPC" => 372,
        "GetIsPC" => 428,
        "GetIsObjectValid" => 429,
        "GetIsDead" => 443,
        "GetIsInCombat" => 444,
        "SetCommandable" => 456,
        "GetCommandable" => 455,
        "ActionDoCommand" => 83,
        "AssignCommand" => 84,
        "DelayCommand" => 85,
        "GetItemPossessedBy" => 298,
        "CreateItemOnObject" => 300,
        "CopyObject" => 303,
        "DestroyObject" => 312,
        "JumpToObject" => 345,
        "JumpToLocation" => 346,
        "ApplyEffectToObject" => 356,
        "GetFirstEffect" => 205,
        "GetNextEffect" => 206,
        "RemoveEffect" => 207,
        "EffectHeal" => 64,
        "EffectDamage" => 65,
        "EffectVisualEffect" => 67,
        "EffectCutsceneGhost" => 381,
        "EffectResurrection" => 397,
        "GetHitDice" => 411,
        "GetLevelByClass" => 412,
        "GetHasFeat" => 413,
        "GetHasSkill" => 414,
        "GetSkillRank" => 415,
        "GetAbilityScore" => 416,
        "GetAC" => 421,
        "PlaySound" => 466,
        "SetFacing" => 468,
        "SetFacingPoint" => 469,
        "ApplyCustomToken" => 529,
        "GetCustomToken" => 530,
        "SetCameraHeight" => 535,
        "GetModule" => 422,
        "GetArea" => 423,
        "GetLocation" => 424,
        "SetTransition" => 476,
        "SetRestTransition" => 477,
        "GetObjectSeen" => 432,
        "GetObjectHeard" => 433,
        "GetLastPerceiver" => 434,
        "GetUseData" => 398,
        "SetUseData" => 399,
        "GetLocked" => 440,
        "SetLocked" => 441,
        "GetIsTrapped" => 434,
        "SetTrapped" => 434,
        "GetTrapBaseType" => 435,
        "GetTrapDetectable" => 435,
        "GetTrapDetected" => 435,
        "GetTrapDisarmable" => 435,
        "GetTrapFlag" => 435,
        "SetTrapDetectable" => 435,
        "SetTrapDetected" => 435,
        "SetTrapDisarmable" => 435,
        "SetTrapFlag" => 435,
        "CreateVisualEffect" => 535,
        "StringSplit" => 550,
        "EffectSuperiorHeal" => 395,
        "EffectLegendaryHeal" => 396,
        "SetName" => 425,
        "GetStrRef" => 497,
        "Random" => 22,
        "Effect" => 64,
        "GetDistanceBetween" => 435,
        "GetDistanceToObject" => 436,
        "StartNewModule" => 496,
        "GetCampaignInt" => 530,
        "SetCampaignInt" => 531,
        "GetCampaignFloat" => 532,
        "SetCampaignFloat" => 533,
        "GetCampaignString" => 534,
        "SetCampaignString" => 535,
        "GetItemInSlot" => 299,
        "UnequipItem" => 301,
        "GetIsEnemy" => 445,
        "GetIsFriend" => 446,
        "GetIsNeutral" => 447,
        "GetGold" => 449,
        "SetGold" => 450,
        "GetSitting" => 453,
        "GetWeather" => 454,
        "GetIsDay" => 455,
        "GetIsNight" => 456,
        "GetIsDawn" => 457,
        "GetIsDusk" => 458,
        "GetXP" => 459,
        "SetXP" => 460,
        "GetMaxHitPoints" => 417,
        "GetCurrentHitPoints" => 418,
        "SetMaxHitPoints" => 419,
        "SetCurrentHitPoints" => 420,
        "GetIsImmortal" => 458,
        "GetIsPlot" => 458,
        "SetIsPlot" => 458,
        "GetPlotFlag" => 458,
        "SetPlotFlag" => 458,
        "GetSoloMode" => 458,
        "SetSoloMode" => 458,
        "GetRunning" => 458,
        "SetRunning" => 458,
        _ => {
            eprintln!("Unknown engine function: {}", name);
            0
        }
    }
}
