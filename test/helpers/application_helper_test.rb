class ApplicationHelperTest < ActionView::TestCase
  test "#active_link_to" do
    assert_dom_equal %(<a href="/">label</a>), active_link_to("label", root_path)

    controller.request.path = root_path
    assert_dom_equal %(<a href="/" class="active">label</a>), active_link_to("label", root_path)
  end

  test "#compute_menu adds empty children" do
    actual = compute_menu([ { expanded: true, label: "Page 1", url: root_path } ])
    expected = [ { expanded: true, label: "Page 1", url: root_path, children: [] } ]
    assert_equal expected, actual
  end

  test "#compute_menu adds expanded (defaulting to false)" do
    actual = compute_menu([ { label: "Page 1", url: root_path } ])
    expected = [ { expanded: false, label: "Page 1", url: root_path, children: [] } ]
    assert_equal expected, actual
  end

  test "#compute_menu adds expanded: true when the url is active" do
    controller.request.path = root_path
    actual = compute_menu([ { label: "Page 1", url: root_path } ])
    expected = [ { expanded: true, label: "Page 1", url: root_path, children: [] } ]
    assert_equal expected, actual
  end

  test "#compute_menu works on children too" do
    actual = compute_menu([
      {
        label: "Page 1", url: root_path, children: [
          { label: "Page 2", url: "#" }
        ]
      }
    ])

    expected = [
      {
        expanded: false, label: "Page 1", url: root_path, children: [
          { expanded: false, label: "Page 2", url: "#", children: [] }
        ]
      }
    ]
    assert_equal expected, actual
  end

  test "#compute_menu adds expanded: true from the active url to the root" do
    controller.request.path = root_path

    actual = compute_menu([
      {
        expanded: false, label: "Page 1", url: "#", children: [
          { expanded: false, label: "Page 2", url: root_path }
        ]
      }
    ])

    expected = [
      {
        expanded: true, label: "Page 1", url: "#", children: [
          { expanded: true, label: "Page 2", url: root_path, children: [] }
        ]
      }
    ]
    assert_equal expected, actual
  end

  test "#menu" do
    actual = menu([
      {
        expanded: true, label: "Page 1", url: "#first", children: [
          {
            label: "Page 2", url: "#second"
          }
        ]
      }
    ])

    expected = <<~HTML
      <ul class="sidebar__section">
        <li>
          #{render partial: "root/sidebar_row", locals: { expanded: true, label: "Page 1", url: "#first" }}

          <ul class="sidebar__section">
            <li>#{render partial: "root/sidebar_row", locals: { label: "Page 2", url: "#second" }}</li>
          </ul>
        </li>
      </ul>
    HTML
    assert_dom_equal expected, actual
  end
end
