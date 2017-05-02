
class BreadCrumbParserTest < ActiveSupport::TestCase

  def test_should_parse_breadcrumbs
    # Given
    test_breadcrumbs = [
      { :breadcrumb => "", :expectation => [] },
      { :breadcrumb => nil, :expectation => [] },
      { :breadcrumb => "foo", :expectation => ["foo"] },
      { :breadcrumb => "foo:bar", :expectation => ["foo", "bar"] },
      { :breadcrumb => "foo:bar:woo:", :expectation => ["foo", "bar", "woo"] },
      { :breadcrumb => "123", :expectation => ["123"] },
      { :breadcrumb => "123:456", :expectation => ["123", "456"] },
      { :breadcrumb => "123:456:", :expectation => ["123", "456"] },
    ]

    test_breadcrumbs.each do |test_crumbs|
      # when
      crumbs = ::Bcome::Parser::BreadCrumb.new(test_crumbs[:breadcrumb]).crumbs
      # then
      assert crumbs == test_crumbs[:expectation]
    end
  end

  def test_should_raise_if_invalid_breadcrumb
    # Given/when/then
    assert_raise Bcome::Exception::InvalidBcomeBreadcrumb do
     ::Bcome::Parser::BreadCrumb.new("-")
    end
  end


end
