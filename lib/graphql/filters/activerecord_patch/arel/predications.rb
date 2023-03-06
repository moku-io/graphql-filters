require_relative 'nodes/contained'

monkey_patch = Module.new do
  def contained other
    Nodes::Contained.new self, Nodes.build_quoted(other, self)
  end
end

Arel::Predications.prepend monkey_patch
