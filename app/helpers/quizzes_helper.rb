module QuizzesHelper
  def show_tag(question, quiz)
    if quiz.goals_stack.any? && question
      form_with(url: quiz_path(quiz.id), method: "post", local: true) do
        %Q`#{label_tag(:value, "Select #{question[:goal]}")}
        #{select_tag(:value, options_for_select(question[:options].map {|o| [o, o]}, question[:options].first))}
        #{hidden_field_tag(:attr, question[:goal])}
        #{submit_tag('Submit')}
        `
      end
    elsif quiz.goals_stack.any? && !question
      "<h1>I don't know</h1><a href='/'> Start new quest </a>"
    else
      "<h1>It's #{quiz.context_stack['aircraft'] || quiz.context_stack['manufacturer']}</h1><a href='/'> Start new quest </a>"
    end
  end
end
