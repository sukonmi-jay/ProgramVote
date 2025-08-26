
;; title: ProgramVote
;; version: 1.0.0
;; summary: A voting system smart contract for academic program approval
;; description: This contract allows authorized voters to create, vote on, and approve academic program proposals

;; traits
;;

;; token definitions
;;

;; constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_VOTED (err u102))
(define-constant ERR_VOTING_CLOSED (err u103))
(define-constant ERR_INVALID_PROPOSAL (err u104))
(define-constant ERR_ALREADY_AUTHORIZED (err u105))

;; Proposal status constants
(define-constant STATUS_ACTIVE u1)
(define-constant STATUS_APPROVED u2)
(define-constant STATUS_REJECTED u3)

;; data vars
(define-data-var next-proposal-id uint u1)

;; data maps
;; Map to store authorized voters
(define-map authorized-voters principal bool)

;; Map to store program proposals
(define-map proposals 
  uint 
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposer: principal,
    votes-for: uint,
    votes-against: uint,
    status: uint,
    voting-deadline: uint
  }
)

;; Map to track who has voted on which proposal
(define-map votes {proposal-id: uint, voter: principal} bool)

;; public functions

;; Initialize contract with the deployer as authorized voter
(define-public (initialize)
  (begin
    (map-set authorized-voters CONTRACT_OWNER true)
    (ok true)
  )
)

;; Add authorized voter (only contract owner can do this)
(define-public (add-authorized-voter (voter principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? authorized-voters voter)) ERR_ALREADY_AUTHORIZED)
    (map-set authorized-voters voter true)
    (ok true)
  )
)

;; Remove authorized voter (only contract owner can do this)
(define-public (remove-authorized-voter (voter principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-delete authorized-voters voter)
    (ok true)
  )
)

;; Create a new program proposal
(define-public (create-proposal 
  (title (string-ascii 100)) 
  (description (string-ascii 500))
  (voting-duration uint))
  (let 
    (
      (proposal-id (var-get next-proposal-id))
      (voting-deadline (+ block-height voting-duration))
    )
    ;; Only authorized voters can create proposals
    (asserts! (default-to false (map-get? authorized-voters tx-sender)) ERR_UNAUTHORIZED)
    (asserts! (> (len title) u0) ERR_INVALID_PROPOSAL)
    (asserts! (> (len description) u0) ERR_INVALID_PROPOSAL)
    (asserts! (> voting-duration u0) ERR_INVALID_PROPOSAL)
    
    ;; Store the proposal
    (map-set proposals proposal-id
      {
        title: title,
        description: description,
        proposer: tx-sender,
        votes-for: u0,
        votes-against: u0,
        status: STATUS_ACTIVE,
        voting-deadline: voting-deadline
      }
    )
    
    ;; Increment proposal ID for next proposal
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

;; Vote on a proposal (true for approve, false for reject)
(define-public (vote (proposal-id uint) (vote-for bool))
  (let 
    (
      (proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
      (vote-key {proposal-id: proposal-id, voter: tx-sender})
    )
    ;; Only authorized voters can vote
    (asserts! (default-to false (map-get? authorized-voters tx-sender)) ERR_UNAUTHORIZED)
    ;; Check if voting is still open
    (asserts! (< block-height (get voting-deadline proposal)) ERR_VOTING_CLOSED)
    ;; Check if proposal is still active
    (asserts! (is-eq (get status proposal) STATUS_ACTIVE) ERR_VOTING_CLOSED)
    ;; Check if user hasn't voted already
    (asserts! (is-none (map-get? votes vote-key)) ERR_ALREADY_VOTED)
    
    ;; Record the vote
    (map-set votes vote-key true)
    
    ;; Update vote counts
    (if vote-for
      (map-set proposals proposal-id 
        (merge proposal {votes-for: (+ (get votes-for proposal) u1)}))
      (map-set proposals proposal-id 
        (merge proposal {votes-against: (+ (get votes-against proposal) u1)}))
    )
    (ok true)
  )
)

;; Finalize a proposal (can be called by anyone, but only works if voting period is over)
(define-public (finalize-proposal (proposal-id uint))
  (let 
    (
      (proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
    )
    ;; Check if voting period is over
    (asserts! (>= block-height (get voting-deadline proposal)) ERR_VOTING_CLOSED)
    ;; Check if proposal is still active
    (asserts! (is-eq (get status proposal) STATUS_ACTIVE) ERR_VOTING_CLOSED)
    
    ;; Determine outcome and update status
    (let 
      (
        (votes-for (get votes-for proposal))
        (votes-against (get votes-against proposal))
        (new-status (if (> votes-for votes-against) STATUS_APPROVED STATUS_REJECTED))
      )
      (map-set proposals proposal-id (merge proposal {status: new-status}))
      (ok new-status)
    )
  )
)

;; read only functions

;; Check if a principal is an authorized voter
(define-read-only (is-authorized-voter (voter principal))
  (default-to false (map-get? authorized-voters voter))
)

;; Get proposal details
(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

;; Get total number of proposals
(define-read-only (get-total-proposals)
  (- (var-get next-proposal-id) u1)
)

;; Check if a user has voted on a specific proposal
(define-read-only (has-voted (proposal-id uint) (voter principal))
  (is-some (map-get? votes {proposal-id: proposal-id, voter: voter}))
)

;; Get proposal status as string
(define-read-only (get-proposal-status-string (proposal-id uint))
  (let 
    (
      (proposal (map-get? proposals proposal-id))
    )
    (match proposal
      proposal-data 
        (let ((status (get status proposal-data)))
          (if (is-eq status STATUS_ACTIVE)
            "ACTIVE"
            (if (is-eq status STATUS_APPROVED)
              "APPROVED"
              "REJECTED"
            )
          )
        )
      "NOT_FOUND"
    )
  )
)

;; private functions
;;

