-- ------------------------------------------------
-- 1. 공통 코드 그룹 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_code_groups (
  id VARCHAR(30) PRIMARY KEY
    COMMENT '코드 그룹 ID (예: CONTENT_TYPE 등)',
  name VARCHAR(100) NOT NULL
    COMMENT '코드 그룹 명칭',
  description TEXT
    COMMENT '코드 그룹 설명',
  use_yn CHAR(1) NOT NULL DEFAULT 'Y'
    COMMENT '사용 여부 (Y/N)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 2. 공통 코드 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_common_codes (
  id VARCHAR(30) NOT NULL
    COMMENT '코드 ID',
  group_id VARCHAR(30) NOT NULL
    COMMENT '코드 그룹 ID (tbl_code_groups.id 참조)',
  name VARCHAR(100) NOT NULL
    COMMENT '코드 명칭',
  value VARCHAR(255) NOT NULL
    COMMENT '코드 값',
  description TEXT
    COMMENT '코드 설명',
  sort_order INT NOT NULL DEFAULT 0
    COMMENT '정렬 순서',
  use_yn CHAR(1) NOT NULL DEFAULT 'Y'
    COMMENT '사용 여부 (Y/N)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  PRIMARY KEY (id, group_id),
  FOREIGN KEY (group_id)
    REFERENCES tbl_code_groups(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tbl_content_type_role_map (
  content_type_id VARCHAR(50) NOT NULL,
  content_role_id VARCHAR(50) NOT NULL,
  PRIMARY KEY (content_type_id, content_role_id),
  FOREIGN KEY (content_type_id) REFERENCES tbl_common_codes(id),
  FOREIGN KEY (content_role_id) REFERENCES tbl_common_codes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 3. 사용자 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_users (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '사용자 고유 ID',
  name VARCHAR(100) NOT NULL
    COMMENT '사용자 이름',
  email VARCHAR(255) NOT NULL UNIQUE
    COMMENT '사용자 이메일 (고유)',
  password VARCHAR(255) NOT NULL
    COMMENT '암호화된 비밀번호',
  role VARCHAR(30) NOT NULL DEFAULT 'student'
    COMMENT '사용자 역할 (예: student, instructor, admin)',
  status VARCHAR(30) NOT NULL DEFAULT 'active'
    COMMENT '사용자 상태 (예: active, inactive, suspended)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 4. 카테고리 테이블 (계층 구조 지원)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_categories (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '카테고리 고유 ID',
  name VARCHAR(100) NOT NULL
    COMMENT '카테고리 이름',
  parent_id INT NULL
    COMMENT '상위 카테고리 ID (자기 자신 참조)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (parent_id)
    REFERENCES tbl_categories(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 5. 태그 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_tags (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '태그 고유 ID',
  name VARCHAR(50) NOT NULL UNIQUE
    COMMENT '태그 이름 (고유)',
  description TEXT
    COMMENT '태그 설명',
  color VARCHAR(7)
    COMMENT '태그 색상',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 6. 스킬 테이블 (계층 구조 지원)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_skills (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '스킬 고유 ID',
  name VARCHAR(100) NOT NULL
    COMMENT '스킬 이름',
  description TEXT
    COMMENT '스킬 설명',
  parent_id INT NULL
    COMMENT '상위 스킬 ID (계층 구조)',
  path VARCHAR(255) NULL
    COMMENT '스킬 경로 (예: frontend/javascript/react)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (parent_id)
    REFERENCES tbl_skills(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 7. 콘텐츠 테이블 (계층 정보 제거)
-- ------------------------------------------------
CREATE TABLE `tbl_contents` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '콘텐츠 고유 ID',
  `title` VARCHAR(255) NOT NULL COMMENT '콘텐츠 제목' COLLATE 'utf8mb4_unicode_ci',
  `description` TEXT NULL DEFAULT NULL COMMENT '콘텐츠 설명' COLLATE 'utf8mb4_unicode_ci',

  -- 변경: content_type 컬럼명을 content_format_id로 변경하고, COMMENT를 수정하여 `CONTENT_FORMAT` 그룹 참조를 명확히 합니다.
  `content_type` VARCHAR(50)  DEFAULT 'NONE' COMMENT '콘텐츠 형태 코드 (tbl_common_codes.id 참조, group_id: CONTENT_TYPE)' COLLATE 'utf8mb4_unicode_ci',
  
  -- 변경: content_role_type 컬럼명을 content_role_id로 변경하고, COMMENT를 수정하여 `CONTENT_ROLE` 그룹 참조를 명확히 합니다.
  `content_role` VARCHAR(50)  COMMENT '콘텐츠 역할 코드 (tbl_common_codes.id 참조, group_id: CONTENT_ROLE)' COLLATE 'utf8mb4_unicode_ci',
  
  -- 추가: 콘텐츠가 속한 코스 구조 단위 (예: 코스, 모듈, 섹션, 레슨 등)를 참조합니다.
  -- 이 컬럼은 tbl_common_codes의 CONTENT_UNIT 그룹을 참조합니다.
  `content_unit` VARCHAR(50) NULL DEFAULT NULL COMMENT '콘텐츠가 속한 코스 단위 코드 (tbl_common_codes.id 참조, group_id: CONTENT_UNIT)' COLLATE 'utf8mb4_unicode_ci',
  
  `duration` INT(11) NULL DEFAULT NULL COMMENT '재생 시간 (초 또는 분 단위, 모든 타입에 필요하지 않을 수 있어 NULL 허용)', -- 기존 NOT NULL 제거
  `difficulty` VARCHAR(30) NOT NULL COMMENT '난이도 코드 (tbl_common_codes.id 참조, group_id: DIFFICULTY_LEVEL)' COLLATE 'utf8mb4_unicode_ci',
  `language` VARCHAR(10) NOT NULL DEFAULT 'ko' COMMENT '언어 코드 (tbl_common_codes.id 참조, group_id: LANGUAGE_CODE)' COLLATE 'utf8mb4_unicode_ci',
  `status` VARCHAR(30) NOT NULL DEFAULT 'draft' COMMENT '콘텐츠 상태 코드 (tbl_common_codes.id 참조, group_id: CONTENT_STATUS)' COLLATE 'utf8mb4_unicode_ci',
  `thumbnail` VARCHAR(255) NULL DEFAULT NULL COMMENT '썸네일 이미지 경로' COLLATE 'utf8mb4_unicode_ci',
  
  `created_by` INT(11) NOT NULL COMMENT '생성자 사용자 ID (tbl_users.id 참조)',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 시각',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 시각',
  
  `category_id` INT(11) NULL DEFAULT NULL COMMENT '카테고리 ID (tbl_categories.id 참조)',
  
  PRIMARY KEY (`id`) USING BTREE,
  
  -- 인덱스명 변경 및 추가
  INDEX `idx_content_type` (`content_type`) USING BTREE,
  INDEX `idx_content_role` (`content_role`) USING BTREE,
  INDEX `idx_content_unit` (`content_unit`) USING BTREE, -- 추가된 인덱스
  INDEX `idx_difficulty` (`difficulty`) USING BTREE,
  INDEX `idx_language` (`language`) USING BTREE, -- 언어 인덱스 추가
  INDEX `idx_status` (`status`) USING BTREE,
  INDEX `idx_created_by` (`created_by`) USING BTREE,
  INDEX `idx_category_id` (`category_id`) USING BTREE, -- 인덱스명 통일
  

  
  CONSTRAINT `fk_contents_created_by` FOREIGN KEY (`created_by`) REFERENCES `tbl_users` (`id`) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT `fk_contents_category` FOREIGN KEY (`category_id`) REFERENCES `tbl_categories` (`id`) ON UPDATE RESTRICT ON DELETE SET NULL
)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1;



-- ------------------------------------------------
-- 8. 콘텐츠 계층 관계 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_hierarchy (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '계층 관계 고유 ID',
  parent_content_id INT NOT NULL
    COMMENT '부모 콘텐츠 ID (tbl_contents.id 참조)',
  child_content_id INT NOT NULL
    COMMENT '하위(자식) 콘텐츠 ID (tbl_contents.id 참조)',
  level INT NOT NULL
    COMMENT '부모-자식 간 거리 (직계=1, 손자=2, …)',
  root_content_id INT NOT NULL
    COMMENT '루트 콘텐츠 ID (최상위 콘텐츠 ID)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '관계 생성 시각',
  FOREIGN KEY (parent_content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (child_content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  UNIQUE KEY uk_parent_child (parent_content_id, child_content_id)
    COMMENT '동일 관계 중복 방지',
  INDEX idx_root_content_id (root_content_id) 
    COMMENT 'root_content_id 인덱스 추가'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------
-- 9. 콘텐츠-태그 관계 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_tags (
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  tag_id INT NOT NULL
    COMMENT '태그 ID (tbl_tags.id 참조)',
  PRIMARY KEY (content_id, tag_id),
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (tag_id)
    REFERENCES tbl_tags(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 10. 콘텐츠-스킬 관계 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_skills (
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  skill_id INT NOT NULL
    COMMENT '스킬 ID (tbl_skills.id 참조)',
  PRIMARY KEY (content_id, skill_id),
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (skill_id)
    REFERENCES tbl_skills(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 11. 콘텐츠 키워드 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_keywords (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '콘텐츠 키워드 고유 ID',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  keyword VARCHAR(100) NOT NULL
    COMMENT '키워드 텍스트',
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 12. 파일 테이블 (콘텐츠 파일 별도 관리)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_files (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '파일 고유 ID',
  file_name VARCHAR(255) NOT NULL
    COMMENT '파일 이름',
  file_path VARCHAR(255) NOT NULL
    COMMENT '파일 저장 경로',
  file_type VARCHAR(50) NOT NULL
    COMMENT '파일 타입 (예: video, document, image 등)',
  file_size BIGINT NOT NULL
    COMMENT '파일 크기 (바이트)',
  mime_type VARCHAR(100) NOT NULL
    COMMENT 'MIME 타입 (예: application/pdf 등)',
  storage_type VARCHAR(30) NOT NULL DEFAULT 'local'
    COMMENT '저장소 유형 코드 (tbl_common_codes.id 참조)',
  storage_path VARCHAR(255) NOT NULL
    COMMENT '저장소 내 경로 (예: S3 버킷 경로 등)',
  checksum VARCHAR(64) NULL
    COMMENT '파일 무결성 검사용 체크섬',
  created_by INT NOT NULL
    COMMENT '파일 업로더 사용자 ID (tbl_users.id 참조)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (created_by)
    REFERENCES tbl_users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 13. 콘텐츠-파일 관계 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_files (
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  file_id INT NOT NULL
    COMMENT '파일 ID (tbl_files.id 참조)',
  file_usage VARCHAR(30) NOT NULL DEFAULT 'main'
    COMMENT '파일 용도 코드 (tbl_common_codes.id 참조)',
  sequence INT NOT NULL DEFAULT 0
    COMMENT '파일 순서',
  PRIMARY KEY (content_id, file_id, file_usage),
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (file_id)
    REFERENCES tbl_files(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 14. 메타데이터 속성 정의 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_metadata_attributes (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '메타데이터 속성 고유 ID',
  attribute_name VARCHAR(100) NOT NULL
    COMMENT '속성 내부 이름 (고유)',
  display_name VARCHAR(100) NOT NULL
    COMMENT '속성 표시 이름',
  description TEXT NULL
    COMMENT '속성 설명',
  data_type ENUM('string','integer','decimal','boolean','date','datetime','file_reference') NOT NULL
    COMMENT '데이터 타입',
  content_type VARCHAR(30) NULL
    COMMENT '적용 대상 콘텐츠 타입 (tbl_common_codes.id 참조)',
  is_required BOOLEAN NOT NULL DEFAULT FALSE
    COMMENT '필수 여부',
  default_value VARCHAR(255) NULL
    COMMENT '기본값',
  validation_rule VARCHAR(255) NULL
    COMMENT '유효성 검사 규칙 (정규식 등)',
  sort_order INT NOT NULL DEFAULT 0
    COMMENT '정렬 순서',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  UNIQUE KEY (attribute_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 15. 메타데이터 속성 그룹 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_metadata_attribute_groups (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '메타데이터 속성 그룹 고유 ID',
  group_name VARCHAR(100) NOT NULL
    COMMENT '그룹 이름 (고유)',
  description TEXT NULL
    COMMENT '그룹 설명',
  content_type VARCHAR(30) NULL
    COMMENT '적용 대상 콘텐츠 타입 (tbl_common_codes.id 참조)',
  sort_order INT NOT NULL DEFAULT 0
    COMMENT '정렬 순서',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  UNIQUE KEY (group_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 16. 메타데이터 속성-그룹 관계 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_metadata_attribute_group_items (
  attribute_id INT NOT NULL
    COMMENT '속성 ID (tbl_metadata_attributes.id 참조)',
  group_id INT NOT NULL
    COMMENT '그룹 ID (tbl_metadata_attribute_groups.id 참조)',
  sort_order INT NOT NULL DEFAULT 0
    COMMENT '정렬 순서',
  PRIMARY KEY (attribute_id, group_id),
  FOREIGN KEY (attribute_id)
    REFERENCES tbl_metadata_attributes(id)
    ON DELETE CASCADE,
  FOREIGN KEY (group_id)
    REFERENCES tbl_metadata_attribute_groups(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 17. 콘텐츠 메타데이터 테이블 (통합)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_metadata (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '콘텐츠 메타데이터 고유 ID',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  attribute_id INT NOT NULL
    COMMENT '속성 ID (tbl_metadata_attributes.id 참조)',
  string_value TEXT NULL
    COMMENT '문자열 값',
  integer_value INT NULL
    COMMENT '정수 값',
  decimal_value DECIMAL(15,5) NULL
    COMMENT '소수 값',
  boolean_value BOOLEAN NULL
    COMMENT '불리언 값',
  date_value DATE NULL
    COMMENT '날짜 값',
  datetime_value DATETIME NULL
    COMMENT '날짜/시간 값',
  file_reference_id INT NULL
    COMMENT '파일 참조 ID (tbl_files.id 참조)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (attribute_id)
    REFERENCES tbl_metadata_attributes(id)
    ON DELETE CASCADE,
  FOREIGN KEY (file_reference_id)
    REFERENCES tbl_files(id)
    ON DELETE SET NULL,
  UNIQUE KEY (content_id, attribute_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 18. 메타데이터 속성 검색 인덱스 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_metadata_search_index (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '메타데이터 검색 인덱스 고유 ID',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  attribute_id INT NOT NULL
    COMMENT '속성 ID (tbl_metadata_attributes.id 참조)',
  search_text TEXT NULL
    COMMENT '검색용 텍스트',
  numeric_value DECIMAL(15,5) NULL
    COMMENT '숫자형 값',
  date_value DATETIME NULL
    COMMENT '날짜/시간 값',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (attribute_id)
    REFERENCES tbl_metadata_attributes(id)
    ON DELETE CASCADE,
  FULLTEXT KEY (search_text),
  INDEX (numeric_value),
  INDEX (date_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 19. 콘텐츠 버전 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_versions (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '버전 고유 ID',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  version_number VARCHAR(20) NOT NULL
    COMMENT '버전 번호',
  change_log TEXT
    COMMENT '변경 로그',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 20. 질문형 콘텐츠 테이블 (퀴즈, 설문, 시험 등)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_assessments (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '평가(Assessment) 고유 ID',
  content_id INT NOT NULL
    COMMENT '연결된 콘텐츠 ID (tbl_contents.id 참조)',
  assessment_type VARCHAR(30) NOT NULL COMMENT 'quiz, survey, exam, assignment'
    COMMENT '평가 유형',
  time_limit INT NULL COMMENT '제한 시간(분)'
    COMMENT '제한 시간(분)',
  passing_score INT NULL COMMENT '통과 점수'
    COMMENT '통과 점수',
  max_attempts INT NULL COMMENT '최대 시도 횟수'
    COMMENT '최대 시도 횟수',
  randomize_questions BOOLEAN NOT NULL DEFAULT FALSE
    COMMENT '문항 섞기 여부',
  show_correct_answers BOOLEAN NOT NULL DEFAULT FALSE
    COMMENT '정답 표시 여부',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 21. 질문 테이블 (options JSON 제거, 별도 테이블 분리)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_questions (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '질문 고유 ID',
  assessment_id INT NOT NULL
    COMMENT '연결된 평가 ID (tbl_assessments.id 참조)',
  question_text TEXT NOT NULL
    COMMENT '질문 텍스트',
  question_type VARCHAR(30) NOT NULL COMMENT 'multiple_choice, true_false, short_answer, essay, matching, etc'
    COMMENT '질문 유형',
  difficulty VARCHAR(30) NULL
    COMMENT '난이도 코드 (tbl_common_codes.id 참조)',
  points INT NOT NULL DEFAULT 1
    COMMENT '문항 배점',
  explanation TEXT NULL COMMENT '정답 설명'
    COMMENT '정답 설명',
  hint TEXT NULL
    COMMENT '힌트 텍스트',
  media_file_id INT NULL
    COMMENT '미디어 파일 ID (tbl_files.id 참조)',
  display_order INT NOT NULL DEFAULT 0
    COMMENT '표시 순서',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (assessment_id)
    REFERENCES tbl_assessments(id)
    ON DELETE CASCADE,
  FOREIGN KEY (media_file_id)
    REFERENCES tbl_files(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 22. 문항 옵션 테이블 (tbl_question_options)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_question_options (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '문항 옵션 고유 ID',
  question_id INT NOT NULL
    COMMENT '질문 ID (tbl_questions.id 참조)',
  option_text VARCHAR(500) NOT NULL
    COMMENT '옵션 텍스트',
  is_correct BOOLEAN NOT NULL DEFAULT FALSE
    COMMENT '정답 여부 (TRUE/FALSE)',
  display_order INT NOT NULL DEFAULT 0
    COMMENT '옵션 표시 순서',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  FOREIGN KEY (question_id)
    REFERENCES tbl_questions(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 23. 사용자 응답 테이블 (tbl_assessment_attempts; responses JSON 제거됨)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_assessment_attempts (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '평가 시도 고유 ID',
  assessment_id INT NOT NULL
    COMMENT '평가 ID (tbl_assessments.id 참조)',
  user_id INT NOT NULL
    COMMENT '사용자 ID (tbl_users.id 참조)',
  attempt_number INT NOT NULL DEFAULT 1
    COMMENT '시도 횟수',
  start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    COMMENT '시작 시각',
  end_time TIMESTAMP NULL
    COMMENT '종료 시각',
  score INT NULL
    COMMENT '획득 점수',
  passed BOOLEAN NULL
    COMMENT '합격 여부',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (assessment_id)
    REFERENCES tbl_assessments(id)
    ON DELETE CASCADE,
  FOREIGN KEY (user_id)
    REFERENCES tbl_users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 24. 응답 항목 테이블 (tbl_attempt_responses)
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_attempt_responses (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '응답 항목 고유 ID',
  attempt_id INT NOT NULL
    COMMENT '시도 ID (tbl_assessment_attempts.id 참조)',
  question_id INT NOT NULL
    COMMENT '질문 ID (tbl_questions.id 참조)',
  answer_text VARCHAR(500) NOT NULL
    COMMENT '응답 텍스트',
  is_correct BOOLEAN NOT NULL DEFAULT FALSE
    COMMENT '정답 여부',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  FOREIGN KEY (attempt_id)
    REFERENCES tbl_assessment_attempts(id)
    ON DELETE CASCADE,
  FOREIGN KEY (question_id)
    REFERENCES tbl_questions(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 25. 콘텐츠 리뷰 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_content_reviews (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '리뷰 고유 ID',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  user_id INT NOT NULL
    COMMENT '리뷰 작성자 ID (tbl_users.id 참조)',
  rating TINYINT NOT NULL 
    COMMENT '평점 (1~5)',
  comment TEXT
    COMMENT '리뷰 코멘트',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (user_id)
    REFERENCES tbl_users(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 26. 콘텐츠 승인 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_approvals (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '승인 기록 고유 ID',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  status VARCHAR(30) NOT NULL DEFAULT 'pending'
    COMMENT '승인 상태 (예: pending, approved, rejected)',
  reviewer_id INT NULL
    COMMENT '검토자 사용자 ID (tbl_users.id 참조)',
  comment TEXT
    COMMENT '검토 코멘트',
  reviewed_at TIMESTAMP NULL
    COMMENT '검토 시각',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  FOREIGN KEY (reviewer_id)
    REFERENCES tbl_users(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 27. 학습 경로 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_learning_paths (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '학습 경로 고유 ID',
  title VARCHAR(255) NOT NULL
    COMMENT '학습 경로 제목',
  description TEXT
    COMMENT '학습 경로 설명',
  target_role VARCHAR(100) NULL
    COMMENT '대상 역할(예: 프론트엔드 개발자)',
  difficulty VARCHAR(30) NOT NULL DEFAULT '1'
    COMMENT '난이도 코드 (tbl_common_codes.id 참조)',
  estimated_time INT NOT NULL DEFAULT 0 COMMENT '분 단위'
    COMMENT '예상 소요 시간(분)',
  created_by INT NOT NULL
    COMMENT '생성자 사용자 ID (tbl_users.id 참조)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (created_by)
    REFERENCES tbl_users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 28. 학습 경로 카테고리 관계 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_learning_path_categories (
  learning_path_id INT NOT NULL
    COMMENT '학습 경로 ID (tbl_learning_paths.id 참조)',
  category_id INT NOT NULL
    COMMENT '카테고리 ID (tbl_categories.id 참조)',
  PRIMARY KEY (learning_path_id, category_id),
  FOREIGN KEY (learning_path_id)
    REFERENCES tbl_learning_paths(id)
    ON DELETE CASCADE,
  FOREIGN KEY (category_id)
    REFERENCES tbl_categories(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 29. 학습 경로 목표 스킬 관계 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_learning_path_target_skills (
  learning_path_id INT NOT NULL
    COMMENT '학습 경로 ID (tbl_learning_paths.id 참조)',
  skill_id INT NOT NULL
    COMMENT '스킬 ID (tbl_skills.id 참조)',
  PRIMARY KEY (learning_path_id, skill_id),
  FOREIGN KEY (learning_path_id)
    REFERENCES tbl_learning_paths(id)
    ON DELETE CASCADE,
  FOREIGN KEY (skill_id)
    REFERENCES tbl_skills(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 30. 학습 경로 항목 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_learning_path_items (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '항목 고유 ID',
  learning_path_id INT NOT NULL
    COMMENT '학습 경로 ID (tbl_learning_paths.id 참조)',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  sequence INT NOT NULL
    COMMENT '순서',
  required BOOLEAN NOT NULL DEFAULT TRUE
    COMMENT '필수 여부',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '생성 시각',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    COMMENT '수정 시각',
  FOREIGN KEY (learning_path_id)
    REFERENCES tbl_learning_paths(id)
    ON DELETE CASCADE,
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 31. 학습 진행 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_learning_progress (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '진행 기록 고유 ID',
  user_id INT NOT NULL
    COMMENT '사용자 ID (tbl_users.id 참조)',
  learning_path_id INT NOT NULL
    COMMENT '학습 경로 ID (tbl_learning_paths.id 참조)',
  content_id INT NOT NULL
    COMMENT '콘텐츠 ID (tbl_contents.id 참조)',
  status VARCHAR(30) NOT NULL DEFAULT 'not_started'
    COMMENT '진행 상태 코드 (tbl_common_codes.id 참조)',
  progress_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00
    COMMENT '진행률 (%)',
  started_at TIMESTAMP NULL
    COMMENT '학습 시작 시각',
  completed_at TIMESTAMP NULL
    COMMENT '학습 완료 시각',
  last_accessed_at TIMESTAMP NULL
    COMMENT '마지막 접근 시각',
  deleted_at TIMESTAMP NULL
    COMMENT '삭제 시각 (소프트 딜리트용)',
  FOREIGN KEY (user_id)
    REFERENCES tbl_users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (learning_path_id)
    REFERENCES tbl_learning_paths(id)
    ON DELETE CASCADE,
  FOREIGN KEY (content_id)
    REFERENCES tbl_contents(id)
    ON DELETE CASCADE,
  UNIQUE KEY (user_id, learning_path_id, content_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 32. 학습 경로 등록 테이블
-- ------------------------------------------------
CREATE TABLE IF NOT EXISTS tbl_learning_path_enrollments (
  id INT AUTO_INCREMENT PRIMARY KEY
    COMMENT '등록 고유 ID',
  user_id INT NOT NULL
    COMMENT '사용자 ID (tbl_users.id 참조)',
  learning_path_id INT NOT NULL
    COMMENT '학습 경로 ID (tbl_learning_paths.id 참조)',
  status VARCHAR(30) NOT NULL DEFAULT 'active'
    COMMENT '등록 상태 (예: active, completed, cancelled)',
  enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    COMMENT '등록 시각',
  completed_at TIMESTAMP NULL
    COMMENT '완료 시각',
  FOREIGN KEY (user_id)
    REFERENCES tbl_users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (learning_path_id)
    REFERENCES tbl_learning_paths(id)
    ON DELETE CASCADE,
  UNIQUE KEY (user_id, learning_path_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------
-- 33. 인덱스 생성
-- ------------------------------------------------
-- ------------------------------------------------
-- Create indexes to optimize queries.
-- ------------------------------------------------




CREATE INDEX idx_tbl_learning_paths_created_by
  ON tbl_learning_paths(created_by);

CREATE INDEX idx_tbl_learning_progress_user
  ON tbl_learning_progress(user_id);

CREATE INDEX idx_tbl_learning_progress_path
  ON tbl_learning_progress(learning_path_id);

CREATE INDEX idx_tbl_learning_path_items_sequence
  ON tbl_learning_path_items(learning_path_id, sequence);

CREATE INDEX idx_tbl_files_file_type
  ON tbl_files(file_type);

CREATE INDEX idx_tbl_files_created_by
  ON tbl_files(created_by);

CREATE INDEX idx_tbl_content_files_file_usage
  ON tbl_content_files(file_usage);

CREATE INDEX idx_tbl_content_files_sequence
  ON tbl_content_files(content_id, sequence);