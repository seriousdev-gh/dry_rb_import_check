class CheckClass
  ImportConst = AST::Node.new(:const, [nil, :Import])

  def initialize(class_node, full_name, filename)
    @class_node = class_node
    @full_name = module_name(class_node, full_name)
    @filename = filename
    @imported_objects = []
    @imported_object_node_map = {}
    @used_objects = []
  end

  def call
    @class_node.children.each do |node|
      find_class_method_calls(node)
    end

    find_imported_object_calls(@class_node)

    print_report
  end

  def print_report
    unused_imports = @imported_objects - @used_objects.uniq
    return if unused_imports.empty?

    unused_imports.each do |import|
    info = @imported_object_node_map[import]
      puts "#{@filename}:#{info[:loc].line}:#{info[:loc].column}: '#{info[:import_string]}' not used"
    end
  end

  def find_imported_object_calls(node)
    return unless node.is_a?(AST::Node)

    if any_send_with_self_receiver?(node)
      @used_objects << node.children.last

      method_args(node).each { find_imported_object_calls _1 }
    else
      node.children.each { find_imported_object_calls _1 }
    end
  end

  def find_class_method_calls(node)
    return unless node.is_a?(AST::Node)

    if node.type == :class
      FindClasses.new(node, @full_name).call
    elsif method_call?(node, nil, :include)
      process_include(node)
    else
      node.children.each { find_class_method_calls(_1) }
    end
  end

  def any_send_with_self_receiver?(node)
    node.type == :send && node.children[0] == nil
  end

  def method_call?(node, receiver, name)
    node.type == :send && node.children[0] == receiver && node.children[1] == name
  end

  def method_args(node)
    node.children[2..]
  end

  def process_include(node)
    include_arg = method_args(node).first
    if method_call?(include_arg, ImportConst, :[])
      process_import(include_arg)
    end
  end

  def process_import(node)
    method_args(node).each do |arg|
      process_import_arg(arg)
    end
  end

  def process_import_arg(arg)
    case arg.type
    when :str then process_import_from_str(arg)
    when :hash then process_import_from_hash(arg)
    else
      raise "Unknown type: #{arg.type}, expected :str or :hash"
    end
  end

  def process_import_from_str(arg)
    import_string = arg.children.first
    add_imported_object(import_string.to_s, arg)
  end

  def process_import_from_hash(arg)
    arg.children.each do |pair|
      add_import_from_pair(pair, arg)
    end
  end

  def add_import_from_pair(pair, node)
    raise "Expected pair, got: #{pair}" if pair.type != :pair

    import_string = pair.children.first.children.first

    add_imported_object(import_string.to_s, node)
  end

  def add_imported_object(import_string, node)
    puts "Class: #{@full_name}. Detected import: #{import_string}" if ENV['DEBUG'] == 'true'
    object_name = import_string.split('.').last.to_sym
    @imported_objects << object_name
    @imported_object_node_map[object_name] = { loc: node.loc, import_string: import_string }
  end

  def module_name(node, full_name)
    name = node.children.first.children.last.to_s
    full_name.empty? ? name : "#{full_name}::#{name}"
  end
end