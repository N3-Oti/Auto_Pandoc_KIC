 -- Word出力用の目次タイトル日本語化フィルター
-- Word出力では変数設定が効かない場合があるため、フィルターで処理

-- タイトル変換マップ
local title_mapping = {
    -- 目次関連
    ["Table of Contents"] = "目次",
    ["Contents"] = "目次",
    ["TABLE OF CONTENTS"] = "目次",
    ["CONTENTS"] = "目次",
    
    -- 図目次関連
    ["List of Figures"] = "図目次",
    ["Figures"] = "図目次",
    ["LIST OF FIGURES"] = "図目次",
    ["FIGURES"] = "図目次",
    
    -- 表目次関連
    ["List of Tables"] = "表目次",
    ["Tables"] = "表目次",
    ["LIST OF TABLES"] = "表目次",
    ["TABLES"] = "表目次"
}

-- ヘッダーテキストを取得するヘルパー関数
local function get_header_text(content)
    local text = ""
    for _, inline in ipairs(content) do
        if inline.t == "Str" then
            text = text .. inline.text
        elseif inline.t == "Space" then
            text = text .. " "
        end
    end
    return text:gsub("^%s*(.-)%s*$", "%1") -- 前後の空白を削除
end

-- Header要素の処理
function Header(el)
    -- 第1レベルのヘッダーをチェック（目次タイトルは通常第1レベル）
    if el.level == 1 then
        local header_text = get_header_text(el.content)
        
        -- タイトルマッピングをチェック
        if title_mapping[header_text] then
            print("タイトル変換: '" .. header_text .. "' → '" .. title_mapping[header_text] .. "'")
            
            -- 新しい日本語タイトルで置換
            local new_content = {pandoc.Str(title_mapping[header_text])}
            el.content = new_content
            
            return el
        end
    end
    
    return el
end

-- Para要素の処理（目次タイトルが段落として生成される場合）
function Para(el)
    local para_text = get_header_text(el.content)
    
    -- タイトルマッピングをチェック
    if title_mapping[para_text] then
        print("段落タイトル変換: '" .. para_text .. "' → '" .. title_mapping[para_text] .. "'")
        
        -- 新しい日本語タイトルで置換
        local new_content = {pandoc.Str(title_mapping[para_text])}
        el.content = new_content
        
        return el
    end
    
    return el
end

-- Div要素の処理（目次がDivで囲まれる場合）
function Div(el)
    -- 目次関連のDivをチェック
    if el.classes then
        for _, class in ipairs(el.classes) do
            if class == "TOC" or class == "toc" or class == "lot" or class == "lof" then
                -- TOC内の要素を再帰的に処理
                return el:walk({
                    Header = Header,
                    Para = Para
                })
            end
        end
    end
    
    return el
end