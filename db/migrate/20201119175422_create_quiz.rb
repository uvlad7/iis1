class CreateQuiz < ActiveRecord::Migration[6.0]
  def change
    create_table :quizzes do |t|
      t.string :goals_stack, array: true
      t.string :context_stack, array: true
      t.string :rejected_rules, array: true

      t.timestamps
    end
  end
end
