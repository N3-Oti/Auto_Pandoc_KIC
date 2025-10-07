-- Pandocの標準的なフィルターパターンに従った実装
local chapter_count = 0
local current_chapter = 0
local section_counts = {}

-- 除外パターンの定義
local exclude_patterns = {
    "目次",
    "内容梗概", 
    "謝辞",
    "参考文献",
    "付録",
    "ListofFigures",
    "ListofTables", 
    "ListofListings",
    "修士論文"
}

-- ヘッダーテキストを取得するヘルパー関数
local function get_header_text(content)
    local text = ""
    for _, inline in ipairs(content) do
        if inline.t == "Str" then
            text = text .. inline.text
        end
    end
    return text
end

-- 除外すべきヘッダーかどうかを判定
local function should_exclude_header(el)
    local header_text = get_header_text(el.content)
    
    -- テキストパターンマッチング
    for _, pattern in ipairs(exclude_patterns) do
        if header_text:find(pattern) then
            return true
        end
    end
    
    -- {-}クラスチェック
    for _, class in ipairs(el.classes or {}) do
        if class == "{-}" then
            return true
        end
    end
    
    return false
end

-- 番号付けを無効化するヘルパー関数
local function make_unnumbered(el)
    el.attributes = el.attributes or {}
    el.attributes.unnumbered = "true"
    
    el.classes = el.classes or {}
    local has_class = false
    for _, class in ipairs(el.classes) do
        if class == "unnumbered" then
            has_class = true
            break
        end
    end
    if not has_class then
        table.insert(el.classes, "unnumbered")
    end
    
    return el
end

-- メインのHeaderフィルター関数
function Header(el)
    -- 除外対象のチェック
    if should_exclude_header(el) then
        local header_text = get_header_text(el.content)
        print("除外: " .. header_text)
        return make_unnumbered(el)
    end
    
    -- 第1レベルのヘッダー（章）の処理
    if el.level == 1 then
        chapter_count = chapter_count + 1
        current_chapter = chapter_count
        section_counts[current_chapter] = 0
        
        -- カスタム章番号を付与
        local prefix = pandoc.Str("第" .. tostring(chapter_count) .. "章")
        el.content:insert(1, pandoc.Space())
        el.content:insert(1, prefix)
        
        local header_text = get_header_text(el.content)
        print("章番号付与: " .. tostring(chapter_count) .. " - " .. header_text)
        
        -- Pandocの自動番号付けを無効化
        return make_unnumbered(el)
    end
    
    -- 第2レベルのヘッダー（セクション）の処理
    if el.level == 2 and current_chapter > 0 then
        section_counts[current_chapter] = section_counts[current_chapter] + 1
        local section_num = section_counts[current_chapter]
        
        -- カスタムセクション番号を付与
        local prefix = pandoc.Str(tostring(current_chapter) .. "." .. tostring(section_num))
        el.content:insert(1, pandoc.Space())
        el.content:insert(1, prefix)
        
        local header_text = get_header_text(el.content)
        print("セクション番号付与: " .. tostring(current_chapter) .. "." .. tostring(section_num) .. " - " .. header_text)
        
        -- Pandocの自動番号付けを無効化
        return make_unnumbered(el)
    end
    
    -- その他のレベルのヘッダーはそのまま
    return el
end
