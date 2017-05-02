
module UnitTestHelper

  def given_a_random_string_of_length(string_length = 50)
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten 
    return (0...string_length).map { o[rand(o.length)] }.join
  end

  def given_estate_setup_params
    description = given_a_random_string_of_length(5)
    identifier = given_a_random_string_of_length(5)
    type = given_a_random_string_of_length(5)

    params = {
      :view_data => {
        :description => description,
        :identifier => identifier,
        :type => type
      }
    }
    return params
  end

  def given_dummy_view_data
    [
      { :type => "collection", :identifier => "one", :description => "I am top level collection hear me roar", :views => [
        { :type => "collection", :identifier => "two", :description => "I am sub collection 1", :views => [
          { :type => "collection", :identifier => "three", :description => "I sub collection 2", :views => [
            { :type => "inventory", :identifier => "four", :description => "I am inventory 1", :network => { :type => "ec2", :credentials_key => "whatever" }}
          ]},
        ]},
      ] }
    ]
  end

  def test_traverse_tree(context, crumbs)
    crumbs.each do |crumb|
      context = context.resources.select{|r| r.identifier == crumb }.first
    end 
    return context 
  end

  def all_nodes_in_tree(context, crumbs)
    nodes = []
    crumbs.each do |crumb|
      context = context.resources.select{|r| r.identifier == crumb }.first
      nodes << context
    end
    return nodes
  end

  def given_a_dummy_estate
    return ::Bcome::Node::Estate.new(given_estate_setup_params)
  end

  def given_a_dummy_collection(add_to_view_params = {})
    return ::Bcome::Node::Collection.new({ :view_data => 
      { :type => "collection", :identifier => given_a_random_string_of_length(5), :description => given_a_random_string_of_length(5) }.merge(add_to_view_params)
    })
  end

end
