defmodule CoursePlanner.CourseControllerTest do
  use CoursePlannerWeb.ConnCase
  alias CoursePlanner.Courses.Course

  import CoursePlanner.Factory

  @valid_attrs %{description: "some content", name: "some content"}
  @invalid_attrs %{}

  setup do
    conn =
      :coordinator
      |> insert()
      |> guardian_login_html()

    {:ok, conn: conn}
  end

  defp login_as(user_type) do
    user_type
    |> insert()
    |> guardian_login_html()
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, course_path(conn, :index)
    assert html_response(conn, 200) =~ "Course types"
  end

  test "lists all entries on index for supervisor" do
    conn = login_as(:supervisor)
    conn = get conn, course_path(conn, :index)
    assert html_response(conn, 200) =~ "Course types"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, course_path(conn, :new)
    assert html_response(conn, 200) =~ "New course"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: @valid_attrs
    assert redirected_to(conn) == course_path(conn, :index)
    assert Repo.get_by(Course, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, course_path(conn, :create), course: @invalid_attrs
    assert html_response(conn, 200) =~ "New course"
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    course = Repo.insert! %Course{name: "English"}
    conn = get conn, course_path(conn, :edit, course)
    assert html_response(conn, 200) =~ "English"
  end

  test "renders not found page when editing non-existent resource", %{conn: conn} do
    conn = get conn, course_path(conn, :edit, -1)
    assert html_response(conn, 404)
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    course = Repo.insert! %Course{}
    conn = put conn, course_path(conn, :update, course), course: @valid_attrs
    assert redirected_to(conn) == course_path(conn, :index)
    assert Repo.get_by(Course, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    course = Repo.insert! %Course{name: "English"}
    conn = put conn, course_path(conn, :update, course), course: @invalid_attrs
    assert html_response(conn, 200) =~ "English"
  end

  test "deletes chosen resource", %{conn: conn} do
    course = Repo.insert! %Course{description: "some content", name: "some content"}
    conn = delete conn, course_path(conn, :delete, course)
    assert redirected_to(conn) == course_path(conn, :index)
    refute Repo.get(Course, course.id)
  end

  test "deletes with an invalid id", %{conn: conn} do
    conn = delete conn, course_path(conn, :delete, -1)
    assert redirected_to(conn) == course_path(conn, :index)
    assert get_flash(conn, "error") == "Course was not found."
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, course_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, course_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, course_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    course = insert(:course)

    conn = get student_conn, course_path(student_conn, :edit, course)
    assert html_response(conn, 403)

    conn = get teacher_conn, course_path(teacher_conn, :edit, course)
    assert html_response(conn, 403)

    conn = get volunteer_conn, course_path(volunteer_conn, :edit, course)
    assert html_response(conn, 403)

    conn = get supervisor_conn, course_path(supervisor_conn, :edit, course)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    course = insert(:course)

    conn = delete student_conn, course_path(student_conn, :delete, course.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, course_path(teacher_conn, :delete, course.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, course_path(volunteer_conn, :delete, course.id)
    assert html_response(conn, 403)

    conn = delete supervisor_conn, course_path(supervisor_conn, :delete, course.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new class for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    conn = get student_conn, course_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, course_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, course_path(volunteer_conn, :new)
    assert html_response(conn, 403)

    conn = get supervisor_conn, course_path(supervisor_conn, :new)
    assert html_response(conn, 403)
  end

  test "does not create class for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    course = insert(:course)

    conn = post student_conn, course_path(student_conn, :create), class: course
    assert html_response(conn, 403)

    conn = post teacher_conn, course_path(teacher_conn, :create), class: course
    assert html_response(conn, 403)

    conn = post volunteer_conn, course_path(volunteer_conn, :create), class: course
    assert html_response(conn, 403)

    conn = post supervisor_conn, course_path(supervisor_conn, :create), class: course
    assert html_response(conn, 403)
  end

  test "does not update chosen course for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    course = Repo.insert! %Course{}

    conn = put student_conn, course_path(student_conn, :update, course), course: @valid_attrs
    assert html_response(conn, 403)

    conn = put teacher_conn, course_path(teacher_conn, :update, course), course: @valid_attrs
    assert html_response(conn, 403)

    conn = put volunteer_conn, course_path(volunteer_conn, :update, course), course: @valid_attrs
    assert html_response(conn, 403)

    conn = put supervisor_conn, course_path(supervisor_conn, :update, course), course: @valid_attrs
    assert html_response(conn, 403)
  end
end
