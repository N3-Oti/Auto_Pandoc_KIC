-- strip_strong.lua
-- Remove Markdown strong emphasis (**) from output.
--
-- Motivation:
-- In some docx conversion flows, raw "**" may survive and introduce odd spacing.
-- This filter ensures:
-- - Parsed strong emphasis (Strong) is rendered as plain text (content only)
-- - Any literal "**" that remains in Str tokens is removed as a safety net

-- Drop strong formatting but keep text.
function Strong(el)
  return el.content
end

-- Safety net: if "**" remained as literal text, remove it.
function Str(el)
  local text = el.text:gsub("%*%*", "")
  if text == "" then
    return {}
  end
  return pandoc.Str(text)
end

