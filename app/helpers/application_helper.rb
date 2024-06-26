# app/helpers/application_helper.rb
module ApplicationHelper
  ATTACK_PHASES = {
    1 => { icon: '⚔️', title: 'Initial Strike', description: 'Start your attack on inaccurate information.' },
    2 => { icon: '🔍', title: 'Second Wave', description: 'Follow up with a thorough reinvestigation.' },
    4 => { icon: '⚖️', title: 'Order in the Court', description: 'Review for legal compliance and accuracy.' },
    3 => { icon: '🔥', title: 'Not Compliant', description: 'Attack based on compliancy' },
    5 => { icon: '🔄', title: 'Reconciliation', description: 'Reconcile discrepancies in your report.' },
    6 => { icon: '🗂️', title: 'Comprehensive Review', description: 'Conduct a comprehensive review of your report.' },
    7 => { icon: '🛡️', title: 'Verification', description: 'Verify the accuracy of updated information.' },
    8 => { icon: '📜', title: 'Inquiries Only', description: 'Inquiries only Attack' },
    9 => { icon: '📜', title: 'Accounts Only', description: 'Accounts only Attack' },
    10 => { icon: '🚨', title: 'Final Demand', description: 'Issue a final demand for corrections.' },
    11 => { icon: '👊', title: 'Bankruptcy Step 1', description: 'Initial stage to attacking your bankrupcty' },
    12 => { icon: '🪖', title: 'Bankruptcy Step 2', description: 'Won the battle but not the war' },
  }.freeze

  def attack_phase_info(round)
    ATTACK_PHASES[round]
  end

  def flash_class(level)
    case level
    when 'notice' then 'border-[#34D399] bg-[#34D399] bg-opacity-[15%]'
    when 'alert' then 'border-[#F87171] bg-[#F87171] bg-opacity-[15%]'
    when 'warning' then 'border-warning bg-warning bg-opacity-[15%]'
    else 'border-stroke bg-white'
    end
  end

  def flash_icon(level)
    case level
    when 'notice' then 'M15.2984 0.826822L15.2868 0.811827L15.2741 0.797751C14.9173 0.401867 14.3238 0.400754 13.9657 0.794406L5.91888 9.45376L2.05667 5.2868C1.69856 4.89287 1.10487 4.89389 0.747996 5.28987C0.417335 5.65675 0.417335 6.22337 0.747996 6.59026L0.747959 6.59029L0.752701 6.59541L4.86742 11.0348C5.14445 11.3405 5.52858 11.5 5.89581 11.5C6.29242 11.5 6.65178 11.3355 6.92401 11.035L15.2162 2.11161C15.5833 1.74452 15.576 1.18615 15.2984 0.826822Z'
    when 'alert' then 'M6.4917 7.65579L11.106 12.2645C11.2545 12.4128 11.4715 12.5 11.6738 12.5C11.8762 12.5 12.0931 12.4128 12.2416 12.2645C12.5621 11.9445 12.5623 11.4317 12.2423 11.1114C12.2422 11.1113 12.2422 11.1113 12.2422 11.1113C12.242 11.1111 12.2418 11.1109 12.2416 11.1107L7.64539 6.50351L12.2589 1.91221L12.2595 1.91158C12.5802 1.59132 12.5802 1.07805 12.2595 0.757793C11.9393 0.437994 11.4268 0.437869 11.1064 0.757418C11.1063 0.757543 11.1062 0.757668 11.106 0.757793L6.49234 5.34931L1.89459 0.740581L1.89396 0.739942C1.57364 0.420019 1.0608 0.420019 0.740487 0.739944C0.42005 1.05999 0.419837 1.57279 0.73985 1.89309L6.4917 7.65579ZM6.4917 7.65579L1.89459 12.2639L1.89395 12.2645C1.74546 12.4128 1.52854 12.5 1.32616 12.5C1.12377 12.5 0.906853 12.4128 0.758361 12.2645L1.1117 11.9108L0.758358 12.2645C0.437984 11.9445 0.437708 11.4319 0.757539 11.1116C0.757812 11.1113 0.758086 11.111 0.75836 11.1107L5.33864 6.50287L0.740487 1.89373L6.4917 7.65579Z'
    when 'warning' then 'M1.50493 16H17.5023C18.6204 16 19.3413 14.9018 18.8354 13.9735L10.8367 0.770573C10.2852 -0.256858 8.70677 -0.256858 8.15528 0.770573L0.156617 13.9735C-0.334072 14.8998 0.386764 16 1.50493 16ZM10.7585 12.9298C10.7585 13.6155 10.2223 14.1433 9.45583 14.1433C8.6894 14.1433 8.15311 13.6155 8.15311 12.9298V12.9015C8.15311 12.2159 8.6894 11.688 9.45583 11.688C10.2223 11.688 10.7585 12.2159 10.7585 12.9015V12.9298ZM8.75236 4.01062H10.2548C10.6674 4.01062 10.9127 4.33826 10.8671 4.75288L10.2071 10.1186C10.1615 10.5049 9.88572 10.7455 9.50142 10.7455C9.11929 10.7455 8.84138 10.5028 8.79579 10.1186L8.13574 4.75288C8.09449 4.33826 8.33984 4.01062 8.75236 4.01062Z'
    else ''
    end
  end

  def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end

  def maverick_payment_form_url
    if Rails.env.production?
      "https://dashboard.maverickpayments.com/gateway/public/form?data=eyJkYmFJZCI6IjE5MDI2NSIsInRlcm1pbmFsSWQiOiI0MTUzMDQiLCJ0aHJlZWRzIjoiRGlzYWJsZWQiLCJleHRlcm5hbElkIjoiIiwicmV0dXJuVXJsIjoiaHR0cHM6XC9cL3d3dy5jcmVkaXRiYWtlLmNvbVwvd2ViaG9va3NcL21hdmVyaWNrP3N0YXR1cz08c3RhdHVzPiZleHRlcm5hbElkPTxleHRlcm5hbElkPiZpZD08aWQ%2BJmFtb3VudD08YW1vdW50PiIsInJldHVyblVybE5hdmlnYXRpb24iOiJ0b3AiLCJsb2dvIjoiWWVzIiwidmlzaWJsZU5vdGUiOiJZZXMiLCJyZXF1ZXN0Q29udGFjdEluZm8iOiJZZXMiLCJyZXF1ZXN0QmlsbGluZ0luZm8iOiJZZXMiLCJzZW5kUmVjZWlwdCI6IlllcyIsIm9yaWdpbiI6Ikhvc3RlZEZvcm0iLCJoYXNoIjoiNzAxYTAxOWViM2M0YjJmYzYxOWQ2ZTM3YjJhMjY5N2UiLCJjb250YWN0SW5mbyI6eyJjb250YWN0TmFtZSI6IiIsImNvbnRhY3RFbWFpbCI6IiIsImNvbnRhY3RQaG9uZSI6IiJ9LCJiaWxsaW5nSW5mbyI6eyJiaWxsaW5nQ291bnRyeSI6IiIsImJpbGxpbmdTdHJlZXQiOiIiLCJiaWxsaW5nU3RyZWV0MiI6IiIsImJpbGxpbmdDaXR5IjoiIiwiYmlsbGluZ1N0YXRlIjoiIiwiYmlsbGluZ1ppcCI6IiJ9fQ%3D%3D&feeType=amount"
    else
      "https://sandbox-dashboard.maverickpayments.com/gateway/public/form?data=eyJkYmFJZCI6IjM4MSIsInRlcm1pbmFsSWQiOiIzNTEiLCJ0aHJlZWRzIjoiRGlzYWJsZWQiLCJleHRlcm5hbElkIjoiIiwicmV0dXJuVXJsIjoiaHR0cHM6XC9cL3d3dy5jcmVkaXRiYWtlLmNvbVwvd2ViaG9va3NcL21hdmVyaWNrXC8%2Fc3RhdHVzPTxzdGF0dXM%2BJmV4dGVybmFsSWQ9PGV4dGVybmFsSWQ%2BJmlkPTxpZD4mYW1vdW50PTxhbW91bnQ%2BIiwicmV0dXJuVXJsTmF2aWdhdGlvbiI6InRvcCIsImxvZ28iOiJZZXMiLCJ2aXNpYmxlTm90ZSI6IlllcyIsInJlcXVlc3RDb250YWN0SW5mbyI6IlllcyIsInJlcXVlc3RCaWxsaW5nSW5mbyI6IlllcyIsInNlbmRSZWNlaXB0IjoiWWVzIiwib3JpZ2luIjoiSG9zdGVkRm9ybSIsImhhc2giOiI0MmVhNTczZmY0ZGU3ZDZlZjNjN2ZmOWE2YzNjYmM1NiIsImNvbnRhY3RJbmZvIjp7ImNvbnRhY3ROYW1lIjoiIiwiY29udGFjdEVtYWlsIjoiIiwiY29udGFjdFBob25lIjoiIn0sImJpbGxpbmdJbmZvIjp7ImJpbGxpbmdDb3VudHJ5IjoiIiwiYmlsbGluZ1N0cmVldCI6IiIsImJpbGxpbmdTdHJlZXQyIjoiIiwiYmlsbGluZ0NpdHkiOiIiLCJiaWxsaW5nU3RhdGUiOiIiLCJiaWxsaW5nWmlwIjoiIn19&feeType=amount"
    end
  end
  
end
