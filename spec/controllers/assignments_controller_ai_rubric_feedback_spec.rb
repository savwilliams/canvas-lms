# frozen_string_literal: true

#
# Copyright (C) 2026 - present Instructure, Inc.
#
# This file is part of Canvas.
#

describe AssignmentsController do
  before :once do
    course_with_teacher(active_all: true)
    student_in_course(active_all: true)
    @assignment = @course.assignments.create!(
      title: "AI feedback assignment",
      submission_types: "online_text_entry"
    )
    rubric = @course.rubrics.create! do |r|
      r.user = @teacher
      r.title = "Test rubric"
      r.data = [{
        description: "Word count (minimum 500)",
        points: 10,
        id: "word_count",
        ratings: [{ description: "Full", points: 10, id: "wc_ex", criterion_id: "word_count" }],
      }]
      r.points_possible = 10
    end
    rubric_association_params = ActiveSupport::HashWithIndifferentAccess.new(
      hide_score_total: "0",
      purpose: "grading",
      skip_updating_points_possible: false,
      update_if_existing: true,
      use_for_grading: "1",
      association_object: @assignment
    )
    @assignment.rubric_association = RubricAssociation.generate(@teacher, rubric, @course, rubric_association_params)
    @assignment.save!
  end

  describe "POST ai_rubric_feedback" do
    before do
      user_session(@student)
    end

    it "returns forbidden when the feature flag is disabled" do
      @course.disable_feature!(:ai_rubric_feedback)
      post :ai_rubric_feedback, params: {
        course_id: @course.id,
        id: @assignment.id,
        draft_text: "draft body"
      }
      assert_status(403)
      expect(json_parse(response.body)).to eq({ "error" => "feature disabled" })
    end

    it "returns rubric-aligned feedback when the feature flag is enabled" do
      @course.enable_feature!(:ai_rubric_feedback)
      post :ai_rubric_feedback, params: {
        course_id: @course.id,
        id: @assignment.id,
        draft_text: "Short draft without thesis or quotes."
      }
      assert_status(200)
      body = json_parse(response.body)
      expect(body["feedback"]["suggestions"]).to be_present
      expect(body["feedback"]["criteria"]).to be_present
      expect(body["feedback"]["weak_areas"]).to be_present
    end

    it "returns unprocessable_entity when draft_text is too long" do
      @course.enable_feature!(:ai_rubric_feedback)
      post :ai_rubric_feedback, params: {
        course_id: @course.id,
        id: @assignment.id,
        draft_text: "word " * 60_000
      }
      assert_status(422)
      expect(json_parse(response.body)).to eq({ "error" => "draft_text too long" })
    end

    it "returns unprocessable_entity when draft_text is blank" do
      @course.enable_feature!(:ai_rubric_feedback)
      post :ai_rubric_feedback, params: {
        course_id: @course.id,
        id: @assignment.id,
        draft_text: "   "
      }
      assert_status(422)
      expect(json_parse(response.body)).to eq({ "error" => "draft_text required" })
    end
  end
end
