defmodule CoursePlanner.Factory do
@moduledoc """
  provides factory function for tests
"""
alias CoursePlanner.Terms.{Term,Holiday}
alias CoursePlanner.{User, Course, OfferedCourse, Class, Attendance, Tasks.Task}

  use ExMachina.Ecto, repo: CoursePlanner.Repo

 def user_factory do
   %User{
     name: sequence(:name, &"user-#{&1}"),
     email: sequence(:email, &"user-#{&1}@courseplanner.com")
   }
 end

 def student_factory do
   %User{
     name: sequence(:name, &"student-#{&1}"),
     email: sequence(:email, &"student-#{&1}@courseplanner.com"),
     role: "Student"
   }
 end

 def teacher_factory do
   %User{
     name: sequence(:name, &"teacher-#{&1}"),
     email: sequence(:email, &"teacher-#{&1}@courseplanner.com"),
     role: "Teacher"
   }
 end

 def coordinator_factory do
   %User{
     name: sequence(:name, &"coordinator-#{&1}"),
     email: sequence(:email, &"coordinator-#{&1}@courseplanner.com"),
     role: "Coordinator"
   }
 end

 def volunteer_factory do
   %User{
     name: sequence(:name, &"volunteer-#{&1}"),
     email: sequence(:email, &"volunteer-#{&1}@courseplanner.com"),
     role: "Volunteer"
   }
 end

 def term_factory do
   %Term{
     name: sequence(:name, &"term-#{&1}"),
     start_date: %Ecto.Date{day: 1, month: 1, year: 2017},
     end_date: %Ecto.Date{day: 1, month: 6, year: 2017},
     minimum_teaching_days: 5
   }
 end

 def course_factory do
  %Course{
     name: sequence(:name, &"course-#{&1}"),
     description: "Description"
  }
 end

 def offered_course_factory do
   %OfferedCourse{
     term: build(:term),
     course: build(:course),
     number_of_sessions: 1,
     syllabus: "some content"
   }
 end

 def class_factory do
    %Class{
      offered_course: build(:offered_course)
    }
 end

 def attendance_factory do
    %Attendance{
      attendance_type: "Not filled"
    }
 end

 def task_factory do
   %Task{
     name: "some content",
     start_time: ~N[2017-01-01 01:00:00],
     finish_time: ~N[2017-02-01 01:00:00],
   }
 end

 def holiday_factory do
    %Holiday{
      date: %Ecto.Date{day: 1, month: 1, year: 2017},
      description: "some description"
    }
 end
end
