require 'rexml/document'
include REXML
module Beautifying
  def beautify(xml, indenter_len)
   output = ""
   Document.new(xml).write(output, indent_spaces = indenter_len)
   output.to_s
  end
end
