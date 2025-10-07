-- 目次、図目次、表目次のタイトルを日本語化するフィルター

-- タイトル変換マップ
local title_mapping = {
    ["Table of Contents"] = "目次",
    ["Contents"] = "目次",
    ["List of Figures"] = "図目次",
    ["Figures"] = "図目次",
    ["List of Tables"] = "表目次",
    ["Tables"] = "表目次"
}

-- Header要素の処理
function Header(el)
    -- 第1レベルのヘッダーをチェック
    if el.level == 1 then
        local header_text = ""
        for _, inline in ipairs(el.content) do
            if inline.t == "Str" then
                header_text = header_text .. inline.text
            end
        end
        
        -- タイトルマッピングをチェック
        if title_mapping[header_text] then
            print("タイトル変換: " .. header_text .. " → " .. title_mapping[header_text])
            
            -- 新しい日本語タイトルで置換
            local new_content = {pandoc.Str(title_mapping[header_text])}
            el.content = new_content
            
            return el
        end
    end
    
    return el
end

-- Div要素の処理（一部の出力形式では目次がDivで囲まれる場合がある）
function Div(el)
    -- 目次関連のDivをチェック
    if el.classes then
        for _, class in ipairs(el.classes) do
            if class == "TOC" or class == "toc" then
                -- TOC内のヘッダーを処理
                return el:walk({
                    Header = Header
                })
            end
        end
    end
    
    return el
end
