class QuizzesController < ApplicationController
  before_action :get_quiz, only: [:show, :update]

  def create
    @quiz = Quiz.create(goals_stack: [params[:goal]], context_stack: {}, rejected_rules: [])
    redirect_to quiz_path(@quiz) if @quiz
  end

  def show
    analyze_rules(@quiz)
    @question = get_question_target(@quiz)
  end

  def update
    @quiz.update!(context_stack: @quiz.context_stack.merge({params[:attr] => params[:value]}), goals_stack: @quiz.goals_stack - [params[:attr]])
    redirect_to quiz_path(@quiz)
  end

  private

  def analyze_rules(quiz)
    loop do
      new_solved_rules, new_context_stack = [], {}
      rules.each_with_index do |rule, index|
        next if quiz.rejected_rules.include?(index.to_s)
        if (rule['if'].keys - quiz.context_stack.keys).empty?
          if (rule['if'].to_a - quiz.context_stack.to_a).empty?
            new_context_stack.merge!(rule['then'])
            rule['then'].each { |attr| quiz.goals_stack.delete(attr) }
          end
          new_solved_rules.push(index.to_s)
        end
        quiz.save!
        quiz.update(context_stack: quiz.context_stack.merge(new_context_stack), rejected_rules: quiz.rejected_rules.concat(new_solved_rules).uniq)
        quiz.reload
      end
      break if new_context_stack.empty? || quiz.goals_stack.empty?
    end

  end

  def get_question_target(quiz)
    goal = quiz.goals_stack.last
    return {goal: goal, options: rules.map { |rule| rule['if'][goal] }.compact.push("Other")} if questions.find(goal)
    new_goal = nil
    rules.each_with_index do |rule, index|
      next if quiz.rejected_rules.include?(index.to_s)
      if rule['then'].keys.include?(goal)
        q = (rule['if'].keys - quiz.context_stack.keys).first
        if q
          quiz.update!(goals_stack: quiz.goals_stack.push(q).uniq)
          return q
        else
          new_goal ||= (rule['if'].keys - quiz.context_stack.keys).first
        end
      end
    end
    return nil unless new_goal
    quiz.update!(goals_stack: (quiz.goals_stack + [new_goal]))
    get_question_target(quiz)
  end

  def rules
    @@rules ||= JSON.parse(File.read('./rules.json'))
  end

  def questions
    @@questions ||= JSON.parse(File.read('./questions.json'))
  end

  def get_quiz
    @quiz = Quiz.find(params[:id])
  end
end
