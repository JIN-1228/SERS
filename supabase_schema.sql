-- ============================================
-- BT Lab LIMS - Supabase (PostgreSQL) Schema
-- ============================================

-- 1. 사용자 테이블
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(200) NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(200) DEFAULT '',
    team VARCHAR(50) DEFAULT '',
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'researcher', 'requester'))
);

-- 2. 효능 평가 카탈로그
CREATE TABLE efficacy_catalog (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    target_marker VARCHAR(200) DEFAULT '',
    cell_line VARCHAR(100) DEFAULT '',
    bt_group VARCHAR(20) DEFAULT 'common' CHECK (bt_group IN ('common', 'BT1', 'BT2', 'BT3')),
    requires_discussion BOOLEAN DEFAULT FALSE
);

-- 3. 의뢰 테이블
CREATE TABLE requests (
    id SERIAL PRIMARY KEY,
    parent_id INTEGER REFERENCES requests(id),
    material_name VARCHAR(200) NOT NULL,
    requester_id INTEGER NOT NULL REFERENCES users(id),
    requester_team VARCHAR(50) DEFAULT '',
    efficacy_types TEXT DEFAULT '',
    concentration VARCHAR(100) DEFAULT '',
    sample_count INTEGER DEFAULT 1,
    characteristics TEXT DEFAULT '',
    has_control BOOLEAN DEFAULT FALSE,
    control_name VARCHAR(200) DEFAULT '',
    control_concentration VARCHAR(100) DEFAULT '',
    urgency VARCHAR(20) DEFAULT '보통' CHECK (urgency IN ('보통', '긴급', '초긴급', '기타')),
    deadline VARCHAR(50) DEFAULT '',
    sample_return VARCHAR(50) DEFAULT '',
    notes TEXT DEFAULT '',
    status VARCHAR(20) DEFAULT 'submitted' CHECK (status IN ('submitted', 'approved_parent', 'pending', 'in_progress', 'documenting', 'completed', 'rejected')),
    researcher_id INTEGER REFERENCES users(id),
    estimated_weeks INTEGER,
    result TEXT DEFAULT '',
    year INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    claimed_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    gmail_sent BOOLEAN DEFAULT FALSE,
    file_path VARCHAR(500) DEFAULT '',
    file_name VARCHAR(200) DEFAULT '',
    file_uploaded_at TIMESTAMPTZ,
    file_requested BOOLEAN DEFAULT FALSE,
    solvent VARCHAR(100) DEFAULT '',
    urgent_reason TEXT DEFAULT '',
    has_specialized BOOLEAN DEFAULT FALSE,
    specialized_types TEXT DEFAULT '',
    specialized_notes TEXT DEFAULT '',
    start_week VARCHAR(50) DEFAULT '',
    is_specialized_child BOOLEAN DEFAULT FALSE,
    assigned_researcher_id INTEGER REFERENCES users(id),
    assigned_team VARCHAR(50) DEFAULT '',
    admin_memo TEXT DEFAULT '',
    sharepoint_url VARCHAR(500) DEFAULT ''
);

-- 4. 채팅 메시지 테이블
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    request_id INTEGER NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
    sender_id INTEGER NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 인덱스
-- ============================================
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_requests_year ON requests(year);
CREATE INDEX idx_requests_requester ON requests(requester_id);
CREATE INDEX idx_requests_researcher ON requests(researcher_id);
CREATE INDEX idx_messages_request ON messages(request_id);
CREATE INDEX idx_messages_created ON messages(request_id, created_at);

-- ============================================
-- 초기 데이터: 사용자
-- ============================================

-- 관리자 (비밀번호: admin123)
INSERT INTO users (username, password, name, email, team, role) VALUES
('admin', 'pbkdf2:sha256:1000000$admin$e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '관리자', 'admin@btlab.com', 'BT Lab', 'admin'),
('nyh',   'temp', '노윤화', 'nyh@btlab.com', 'BT Lab', 'admin');

-- 실험자 (비밀번호: 1234)
INSERT INTO users (username, password, name, email, team, role) VALUES
('lke',  'temp', '이경은', 'lke@btlab.com',  'BT1', 'researcher'),
('kmj',  'temp', '김민지', 'kmj@btlab.com',  'BT1', 'researcher'),
('pjy',  'temp', '박정연', 'pjy@btlab.com',  'BT1', 'researcher'),
('pej',  'temp', '박은진', 'pej@btlab.com',  'BT1', 'researcher'),
('jhy',  'temp', '조희연', 'jhy@btlab.com',  'BT1', 'researcher'),
('rdy',  'temp', '류다연', 'rdy@btlab.com',  'BT1', 'researcher'),
('kms',  'temp', '김미선', 'kms@btlab.com',  'BT2', 'researcher'),
('ks',   'temp', '김솔',   'ks@btlab.com',   'BT2', 'researcher'),
('khy',  'temp', '김혜연', 'khy@btlab.com',  'BT2', 'researcher'),
('kmsg', 'temp', '김민상', 'kmsg@btlab.com', 'BT2', 'researcher'),
('pyj',  'temp', '박연지', 'pyj@btlab.com',  'BT2', 'researcher'),
('ksy',  'temp', '경서연', 'ksy@btlab.com',  'BT1', 'researcher'),
('ksh',  'temp', '김세현', 'ksh@btlab.com',  'BT3', 'researcher'),
('rkm',  'temp', '류경민', 'rkm@btlab.com',  'BT3', 'researcher'),
('lsh',  'temp', '임소희', 'lsh@btlab.com',  'BT3', 'researcher');

-- 의뢰자 (비밀번호: 1234)
INSERT INTO users (username, password, name, email, team, role) VALUES
('lhe', 'temp', '이하은', 'lhe@btlab.com', 'MB2', 'requester'),
('kjh', 'temp', '김지현', 'kjh@btlab.com', 'BI1', 'requester'),
('cyj', 'temp', '최유진', 'cyj@btlab.com', 'BI2', 'requester'),
('phj', 'temp', '박현준', 'phj@btlab.com', 'MB1', 'requester'),
('sjw', 'temp', '송지원', 'sjw@btlab.com', 'BI3', 'requester');

-- ============================================
-- 초기 데이터: 효능 평가 카탈로그
-- ============================================

-- BT Lab 공통 (사전 협의 불필요)
INSERT INTO efficacy_catalog (name, target_marker, cell_line, bt_group, requires_discussion) VALUES
('항노화',      'MMP-1',           'HS68 (fibroblast)',    'common', FALSE),
('탄력',        'Col, ELN, FBN',   'HS68 (fibroblast)',    'common', FALSE),
('재생',        'Migration',       'HS68 (fibroblast)',    'common', FALSE),
('보습/수분',   'HAS3, AQP3',      'HaCaT (keratinocyte)', 'common', FALSE),
('장벽',        'FLG, CLDN, IVL',  'HaCaT (keratinocyte)', 'common', FALSE),
('진정',        'IL-1b, IL-6, TNFa','HaCaT (keratinocyte)', 'common', FALSE),
('가려움 개선', 'TSLP',            'HaCaT (keratinocyte)', 'common', FALSE),
('표피 증식',   'PCNA, KI67',      'HaCaT (keratinocyte)', 'common', FALSE),
('멜라닌 억제', 'Melanin contents','B16F10 (Melanocyte)',  'common', FALSE),
('지질 억제',   'SREBP',           'SZ95 (Sebocyte)',      'common', FALSE),
('독성',        'Cell viability',  'HS68, HaCaT, B16F10',  'common', FALSE),
('항산화',      '-',               'DPPH solution',        'common', FALSE),
('냉감',        'TRPM8, CIRBP',    'HaCaT (keratinocyte)', 'common', FALSE);

-- BT1 전문 평가 (사전 협의 필요)
INSERT INTO efficacy_catalog (name, target_marker, cell_line, bt_group, requires_discussion) VALUES
('열노화',     '', '', 'BT1', TRUE),
('립',         '', '', 'BT1', TRUE),
('저산소',     '', '', 'BT1', TRUE),
('미세먼지',   '', '', 'BT1', TRUE),
('반려동물',   '', '', 'BT1', TRUE);

-- BT2 전문 평가 (사전 협의 필요)
INSERT INTO efficacy_catalog (name, target_marker, cell_line, bt_group, requires_discussion) VALUES
('항노화',     '', '', 'BT2', TRUE),
('3D skin',    '', '', 'BT2', TRUE),
('explant',    '', '', 'BT2', TRUE),
('흡수도',     '', '', 'BT2', TRUE);

-- BT3 전문 평가 (사전 협의 필요)
INSERT INTO efficacy_catalog (name, target_marker, cell_line, bt_group, requires_discussion) VALUES
('헤어',       '', '', 'BT3', TRUE),
('두피 개선',  '', '', 'BT3', TRUE),
('ATP',        '', '', 'BT3', TRUE);
