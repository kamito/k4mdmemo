module K4mdmemo

  class MarkdownRenderer < ::Redcarpet::Render::HTML
    def list_item(text, list_type)
      r = /^\[(\s|x)\]\s/
      m = r.match(text)
      if m
        input_tag = "<input type=\"checkbox\""
        input_tag << "checked=\"true\"" if m[1] and m[1] == 'x'
        input_tag << ">"
        text = text.gsub(r, '')
        text = "#{input_tag} #{text}"
      end
      tag = "<li>#{text}</li>"
      return tag
    end
  end

end
