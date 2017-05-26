load "#{File.dirname(__FILE__)}/../base.rb"

class NodeTest < ActiveSupport::TestCase
  include ::UnitTestHelper

  def test_should_test_wiring_for_cd
    # Given
    estate_identifier = 'estatename'
    node_identifier = 'myservername'

    config = {
      type: 'collection',
      description: 'a top level view',
      identifier: estate_identifier,
      views: [
        { type: 'collection', description: 'a collection', identifier: node_identifier }
      ]
    }

    YAML.expects(:load_file).returns(config)
    estate = ::Bcome::Node::Factory.instance.init_tree
    node = estate.resources.first

    ::Bcome::Workspace.instance.expects(:set).with(current_context: estate, context: node)

    # When
    estate.cd(node_identifier)

    # And all our assumptions are met
  end
end
