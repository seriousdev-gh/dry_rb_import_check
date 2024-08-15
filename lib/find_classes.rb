require_relative 'check_class'

class FindClasses
  RECURSIVE_TYPES = [:begin, :module]

  def initialize(node, filename, full_name = '')
    @node = node
    @full_name = full_name
    @filename = filename
  end

  def call
    find_classes(@node, @full_name)
  end

  private

  def find_classes(node, full_name)
    return if node.nil?

    if node.type == :module
      full_name = module_name(node, full_name)
    end

    if node.type == :class
      CheckClass.new(node, full_name, @filename).call
    end

    if RECURSIVE_TYPES.include?(node.type)
      node.children.each { find_classes(_1, full_name) }
    end
  end

  def module_name(node, full_name)
    name = node.children.first.children.last.to_s
    full_name.empty? ? name : "#{full_name}::#{name}"
  end
end