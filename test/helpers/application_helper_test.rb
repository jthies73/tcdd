require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "encouraging_message_for_cigarettes returns message for nil count" do
    assert_equal "Jede Kippe zählt! Weiter so!", encouraging_message_for_cigarettes(nil)
  end

  test "encouraging_message_for_cigarettes returns message for 0 cigarettes" do
    assert_equal "Jede Kippe zählt! Weiter so!", encouraging_message_for_cigarettes(0)
  end

  test "encouraging_message_for_cigarettes returns message for 1-99 cigarettes" do
    assert_equal "Jede Kippe zählt! Weiter so!", encouraging_message_for_cigarettes(1)
    assert_equal "Jede Kippe zählt! Weiter so!", encouraging_message_for_cigarettes(50)
    assert_equal "Jede Kippe zählt! Weiter so!", encouraging_message_for_cigarettes(99)
  end

  test "encouraging_message_for_cigarettes returns message for 100-499 cigarettes" do
    assert_equal "Super Leistung! Gemeinsam schaffen wir mehr!", encouraging_message_for_cigarettes(100)
    assert_equal "Super Leistung! Gemeinsam schaffen wir mehr!", encouraging_message_for_cigarettes(250)
    assert_equal "Super Leistung! Gemeinsam schaffen wir mehr!", encouraging_message_for_cigarettes(499)
  end

  test "encouraging_message_for_cigarettes returns message for 500-999 cigarettes" do
    assert_equal "Fantastische Arbeit! Ihr seid großartig!", encouraging_message_for_cigarettes(500)
    assert_equal "Fantastische Arbeit! Ihr seid großartig!", encouraging_message_for_cigarettes(750)
    assert_equal "Fantastische Arbeit! Ihr seid großartig!", encouraging_message_for_cigarettes(999)
  end

  test "encouraging_message_for_cigarettes returns message for 1000-1999 cigarettes" do
    assert_equal "Über 1.000 Kippen gesammelt! Unglaublich!", encouraging_message_for_cigarettes(1000)
    assert_equal "Über 1.000 Kippen gesammelt! Unglaublich!", encouraging_message_for_cigarettes(1500)
    assert_equal "Über 1.000 Kippen gesammelt! Unglaublich!", encouraging_message_for_cigarettes(1999)
  end

  test "encouraging_message_for_cigarettes returns message for 2000+ cigarettes" do
    assert_equal "Herausragende Leistung! Ihr seid Helden!", encouraging_message_for_cigarettes(2000)
    assert_equal "Herausragende Leistung! Ihr seid Helden!", encouraging_message_for_cigarettes(5000)
    assert_equal "Herausragende Leistung! Ihr seid Helden!", encouraging_message_for_cigarettes(10000)
  end
end
