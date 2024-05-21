class BureauDetail < ApplicationRecord
  belongs_to :account
  enum bureau: { experian: 0, equifax: 1, transunion: 2 }
end
