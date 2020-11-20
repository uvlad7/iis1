class Quiz < ApplicationRecord
  serialize :goals_stack, JSON
  serialize :context_stack, JSON
  serialize :rejected_rules, JSON
end
