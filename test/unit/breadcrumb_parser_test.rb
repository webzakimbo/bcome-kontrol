
class BreadCrumbParserTest < ActiveSupport::TestCase
  def test_should_parse_breadcrumbs
    # Given
    test_breadcrumbs = [
      { breadcrumb: 'foo', expectation: ['foo'] },
      { breadcrumb: 'foo:bar', expectation: %w[foo bar] },
      { breadcrumb: 'foo:bar:woo:', expectation: %w[foo bar woo] },
      { breadcrumb: '123', expectation: ['123'] },
      { breadcrumb: '123:456', expectation: %w[123 456] },
      { breadcrumb: '123:456:', expectation: %w[123 456] },
      { breadcrumb: '123_:456:', expectation: %w[123_ 456] },
      { breadcrumb: '123:do_foo:', expectation: %w[123 do_foo] },
      { breadcrumb: '123:do_foo_:', expectation: %w[123 do_foo_] },
      { breadcrumb: '_123:456:', expectation: %w[_123 456] },
    ]

    test_breadcrumbs.each do |test_crumbs|
      # when
      crumbs = ::Bcome::Parser::BreadCrumb.new(test_crumbs[:breadcrumb]).crumbs
      # then
      assert crumbs == test_crumbs[:expectation]
    end
  end

end
