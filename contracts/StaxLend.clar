;; DeFi-StaxLend: Decentralized lending protocol on Stacks
;; Version: 1.0.0

(define-data-var minimum-collateral-ratio uint u150)
(define-data-var liquidation-fee uint u10)
(define-map deposits { user: principal } { amount: uint, last-deposit: uint })
(define-map loans { borrower: principal } { amount: uint, collateral: uint, interest-rate: uint })

(define-read-only (get-deposit (user principal))
  (default-to { amount: u0, last-deposit: u0 } (map-get? deposits {user: user}))
)

(define-read-only (get-loan (borrower principal))
  (default-to { amount: u0, collateral: u0, interest-rate: u0 } (map-get? loans {borrower: borrower}))
)

(define-public (deposit (amount uint))
  (let ((current-balance (get-deposit tx-sender)))
    (begin
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set deposits 
        { user: tx-sender } 
        { amount: (+ amount (get amount current-balance)), last-deposit: u0 })
      (ok amount)
    )
  )
)

(define-public (withdraw (amount uint))
  (let ((current-balance (get-deposit tx-sender)))
    (begin
      (asserts! (<= amount (get amount current-balance)) (err u1))
      (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
      (map-set deposits 
        { user: tx-sender } 
        { amount: (- (get amount current-balance) amount), last-deposit: (get last-deposit current-balance) })
      (ok amount)
    )
  )
)

(define-public (borrow (amount uint) (collateral uint))
  (let (
    (user-loan (get-loan tx-sender))
    (collateral-ratio (/ (* collateral u100) amount))
  )
    (begin
      (asserts! (> collateral-ratio (var-get minimum-collateral-ratio)) (err u2))
      (try! (stx-transfer? collateral tx-sender (as-contract tx-sender)))
      (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
      (map-set loans 
        { borrower: tx-sender } 
        { 
          amount: (+ amount (get amount user-loan)), 
          collateral: (+ collateral (get collateral user-loan)), 
          interest-rate: u5 
        })
      (ok amount)
    )
  )
)

(define-public (repay (amount uint))
  (let ((user-loan (get-loan tx-sender)))
    (begin
      (asserts! (<= amount (get amount user-loan)) (err u3))
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set loans 
        { borrower: tx-sender } 
        { 
          amount: (- (get amount user-loan) amount), 
          collateral: (get collateral user-loan), 
          interest-rate: (get interest-rate user-loan) 
        })
      (ok amount)
    )
  )
)

(define-public (claim-collateral (amount uint))
  (let ((user-loan (get-loan tx-sender)))
    (begin
      (asserts! (<= amount (get collateral user-loan)) (err u4))
      (asserts! (is-eq (get amount user-loan) u0) (err u5))
      (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
      (map-set loans 
        { borrower: tx-sender } 
        { 
          amount: u0, 
          collateral: (- (get collateral user-loan) amount), 
          interest-rate: (get interest-rate user-loan) 
        })
      (ok amount)
    )
  )
)