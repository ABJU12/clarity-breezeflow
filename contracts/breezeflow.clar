;; BreezeFlow Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-weather (err u101))
(define-constant err-invalid-activity (err u102))
(define-constant err-already-voted (err u103))

;; Data Variables
(define-map activities-by-weather 
  { weather-condition: (string-ascii 20) }
  { activities: (list 20 principal) }
)

(define-map activity-votes
  { activity-id: uint }
  { votes: uint, weather: (string-ascii 20) }
)

(define-map user-votes
  { user: principal, activity-id: uint }
  { voted: bool }
)

(define-data-var activity-counter uint u0)

;; Public Functions
(define-public (submit-activity (weather (string-ascii 20)) (activity (string-ascii 50)))
  (let ((activity-id (+ (var-get activity-counter) u1)))
    (begin
      (map-set activity-votes
        { activity-id: activity-id }
        { votes: u0, weather: weather }
      )
      (var-set activity-counter activity-id)
      (ok activity-id)))
)

(define-public (vote-activity (activity-id uint))
  (let ((existing-vote (default-to 
    { voted: false }
    (map-get? user-votes { user: tx-sender, activity-id: activity-id }))))
    (if (get voted existing-vote)
      err-already-voted
      (begin
        (map-set user-votes
          { user: tx-sender, activity-id: activity-id }
          { voted: true }
        )
        (ok true))))
)

;; Read-only Functions
(define-read-only (get-activities-for-weather (weather (string-ascii 20)))
  (ok (map-get? activities-by-weather { weather-condition: weather }))
)

(define-read-only (get-activity-votes (activity-id uint))
  (ok (map-get? activity-votes { activity-id: activity-id }))
)
