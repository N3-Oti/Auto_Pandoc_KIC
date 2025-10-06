local chapter_count = 0

local function ensure_table(value)
    if type(value) == "table" then
        return value
    end
    return {}
end

function Header(el)
    if el.level ~= 1 then
        return el
    end

    chapter_count = chapter_count + 1

    -- mark the header as unnumbered so pandoc does not prepend its own numerals
    el.attributes = ensure_table(el.attributes)
    el.classes = ensure_table(el.classes)

    if not el.attributes.unnumbered then
        el.attributes.unnumbered = "true"
    end

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

    local prefix = pandoc.Str("第" .. tostring(chapter_count) .. "章")

    el.content:insert(1, pandoc.Space())
    el.content:insert(1, prefix)

    return el
end
