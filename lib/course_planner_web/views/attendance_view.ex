defmodule CoursePlannerWeb.AttendanceView do
  @moduledoc false
  use CoursePlannerWeb, :view

  alias CoursePlannerWeb.SharedView
  alias CoursePlanner.Settings

  def get_teacher_display_name(offered_course_teachers) do
    offered_course_teachers
    |> Enum.map(fn(teacher) -> SharedView.display_user_name(teacher) end)
    |> Enum.join(", ")
  end

  def page_title do
    "Attendances"
  end

  def attendance_comment_options do
    "ATTENDANCE_DESCRIPTIONS"
    |> Settings.get_value()
    |> Map.new(fn (option) -> {option, option} end)
    |> Map.merge(%{"Not set": ""})
  end

  def get_offered_course_students(offered_course) do
    one_class =
      offered_course.classes
      |> List.first()

    Enum.map(one_class.attendances, &(&1.student))
  end
end
