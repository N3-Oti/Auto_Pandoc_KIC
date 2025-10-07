 -- Word出力用の目次タイトル日本語化フィルター
-- Word出力では変数設定が効かない場合があるため、フィルターで処理

print("目次タイトル日本語化フィルターが開始されました")

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

-- Pandocのtable_of_contents関数を使用して目次を生成
function Pandoc(doc)
    -- 既存の目次を検索して置換
    local blocks = doc.blocks
    
    for i, block in ipairs(blocks) do
        if block.t == "TableOfContents" then
            print("TableOfContents要素を検出しました")
            -- 目次を日本語タイトルで再生成
            local toc = pandoc.utils.table_of_contents(doc.blocks, {
                depth = 3,
                default_section_numbering = true
            })
            
            -- 目次のタイトルを日本語に変更
            if toc and #toc.blocks > 0 then
                for j, toc_block in ipairs(toc.blocks) do
                    if toc_block.t == "Header" and toc_block.level == 1 then
                        local header_text = get_header_text(toc_block.content)
                        if header_text == "Table of Contents" or header_text == "Contents" then
                            print("目次タイトルを検出: '" .. header_text .. "' → '目次'")
                            toc_block.content = {pandoc.Str("目次")}
                        end
                    end
                end
            end
            
            -- 既存の目次を置換
            blocks[i] = toc
        end
    end
    
    return pandoc.Pandoc(blocks, doc.meta)
end

-- タイトル変換マップ
local title_mapping = {
    -- 目次関連
    ["Table of Contents"] = "目次",
    ["Contents"] = "目次",
    ["TABLE OF CONTENTS"] = "目次",
    ["CONTENTS"] = "目次",
    ["目次"] = "目次", -- 既に日本語の場合
    
    -- 図目次関連
    ["List of Figures"] = "図目次",
    ["Figures"] = "図目次",
    ["LIST OF FIGURES"] = "図目次",
    ["FIGURES"] = "図目次",
    ["図目次"] = "図目次", -- 既に日本語の場合
    
    -- 表目次関連
    ["List of Tables"] = "表目次",
    ["Tables"] = "表目次",
    ["LIST OF TABLES"] = "表目次",
    ["TABLES"] = "表目次",
    ["表目次"] = "表目次", -- 既に日本語の場合
    
    -- リスト目次関連
    ["List of Listings"] = "コード目次",
    ["Listings"] = "コード目次",
    ["LIST OF LISTINGS"] = "コード目次",
    ["LISTINGS"] = "コード目次"
}

-- Header要素の処理
function Header(el)
    -- デバッグ出力：すべての第1レベルヘッダーを確認
    if el.level == 1 then
        local header_text = get_header_text(el.content)
        print("第1レベルヘッダー検出: '" .. header_text .. "'")
        
        -- タイトルマッピングをチェック
        if title_mapping[header_text] then
            print("タイトル変換: '" .. header_text .. "' → '" .. title_mapping[header_text] .. "'")
            
            -- 新しい日本語タイトルで置換
            local new_content = {pandoc.Str(title_mapping[header_text])}
            el.content = new_content
            
            return el
        else
            print("変換対象外: '" .. header_text .. "'")
        end
    end
    
    return el
end

-- Para要素の処理（目次タイトルが段落として生成される場合）
function Para(el)
    local para_text = get_header_text(el.content)
    
    -- 空でない段落のみチェック
    if para_text ~= "" then
        print("段落テキスト検出: '" .. para_text .. "'")
        
        -- タイトルマッピングをチェック
        if title_mapping[para_text] then
            print("段落タイトル変換: '" .. para_text .. "' → '" .. title_mapping[para_text] .. "'")
            
            -- 新しい日本語タイトルで置換
            local new_content = {pandoc.Str(title_mapping[para_text])}
            el.content = new_content
            
            return el
        end
    end
    
    return el
end

-- Div要素の処理（目次がDivで囲まれる場合）
function Div(el)
    -- 目次関連のDivをチェック
    if el.classes then
        for _, class in ipairs(el.classes) do
            if class == "TOC" or class == "toc" or class == "lot" or class == "lof" then
                print("目次関連Div検出: " .. class)
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

-- すべての要素をチェックするための汎用フィルター
function Blocks(blocks)
    print("Blocks要素処理開始: " .. #blocks .. "個のブロック")
    
    -- 各ブロックを処理
    for i, block in ipairs(blocks) do
        if block.t == "Header" and block.level == 1 then
            local header_text = get_header_text(block.content)
            print("Blocks内第1レベルヘッダー: '" .. header_text .. "'")
            
            if title_mapping[header_text] then
                print("Blocks内タイトル変換: '" .. header_text .. "' → '" .. title_mapping[header_text] .. "'")
                block.content = {pandoc.Str(title_mapping[header_text])}
            end
        elseif block.t == "Para" then
            -- 段落もチェック（目次タイトルが段落として生成される場合）
            local para_text = get_header_text(block.content)
            if para_text ~= "" and title_mapping[para_text] then
                print("Blocks内段落タイトル変換: '" .. para_text .. "' → '" .. title_mapping[para_text] .. "'")
                block.content = {pandoc.Str(title_mapping[para_text])}
            end
        end
    end
    
    return blocks
end