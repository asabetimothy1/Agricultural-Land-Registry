(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-transfer (err u104))
(define-constant err-pending-dispute (err u105))

(define-data-var next-land-id uint u1)
(define-data-var next-dispute-id uint u1)

(define-map lands
    { land-id: uint }
    {
        owner: principal,
        location: (string-ascii 100),
        size: uint,
        land-type: (string-ascii 50),
        value: uint,
        registered-at: uint,
        last-updated: uint
    }
)

(define-map land-history
    { land-id: uint, transaction-id: uint }
    {
        from: principal,
        to: principal,
        transaction-type: (string-ascii 20),
        timestamp: uint,
        value: uint
    }
)

(define-map usage-rights
    { land-id: uint, user: principal }
    {
        rights-type: (string-ascii 30),
        start-block: uint,
        end-block: uint,
        terms: (string-ascii 200)
    }
)

(define-map disputes
    { dispute-id: uint }
    {
        land-id: uint,
        complainant: principal,
        defendant: principal,
        status: (string-ascii 20),
        filed-at: uint,
        resolved-at: (optional uint)
    }
)

(define-map land-transactions
    { land-id: uint }
    { transaction-count: uint }
)

(define-public (register-land (location (string-ascii 100)) (size uint) (land-type (string-ascii 50)) (value uint))
    (let
        (
            (land-id (var-get next-land-id))
            (current-block stacks-block-height)
        )
        (map-set lands
            { land-id: land-id }
            {
                owner: tx-sender,
                location: location,
                size: size,
                land-type: land-type,
                value: value,
                registered-at: current-block,
                last-updated: current-block
            }
        )
        (map-set land-transactions { land-id: land-id } { transaction-count: u0 })
        (var-set next-land-id (+ land-id u1))
        (ok land-id)
    )
)

(define-public (transfer-land (land-id uint) (new-owner principal))
    (let
        (
            (land-data (unwrap! (map-get? lands { land-id: land-id }) err-not-found))
            (current-block stacks-block-height)
            (transaction-count (get transaction-count (default-to { transaction-count: u0 } (map-get? land-transactions { land-id: land-id }))))
        )
        (asserts! (is-eq (get owner land-data) tx-sender) err-unauthorized)
        (asserts! (not (has-pending-dispute land-id)) err-pending-dispute)
        (map-set lands
            { land-id: land-id }
            (merge land-data {
                owner: new-owner,
                last-updated: current-block
            })
        )
        (map-set land-history
            { land-id: land-id, transaction-id: transaction-count }
            {
                from: tx-sender,
                to: new-owner,
                transaction-type: "transfer",
                timestamp: current-block,
                value: (get value land-data)
            }
        )
        (map-set land-transactions { land-id: land-id } { transaction-count: (+ transaction-count u1) })
        (ok true)
    )
)

(define-public (update-land-value (land-id uint) (new-value uint))
    (let
        (
            (land-data (unwrap! (map-get? lands { land-id: land-id }) err-not-found))
            (current-block stacks-block-height)
        )
        (asserts! (is-eq (get owner land-data) tx-sender) err-unauthorized)
        (map-set lands
            { land-id: land-id }
            (merge land-data {
                value: new-value,
                last-updated: current-block
            })
        )
        (ok true)
    )
)

(define-public (grant-usage-rights (land-id uint) (user principal) (rights-type (string-ascii 30)) (duration uint) (terms (string-ascii 200)))
    (let
        (
            (land-data (unwrap! (map-get? lands { land-id: land-id }) err-not-found))
            (current-block stacks-block-height)
            (end-block (+ current-block duration))
        )
        (asserts! (is-eq (get owner land-data) tx-sender) err-unauthorized)
        (map-set usage-rights
            { land-id: land-id, user: user }
            {
                rights-type: rights-type,
                start-block: current-block,
                end-block: end-block,
                terms: terms
            }
        )
        (ok true)
    )
)

(define-public (revoke-usage-rights (land-id uint) (user principal))
    (let
        (
            (land-data (unwrap! (map-get? lands { land-id: land-id }) err-not-found))
        )
        (asserts! (is-eq (get owner land-data) tx-sender) err-unauthorized)
        (map-delete usage-rights { land-id: land-id, user: user })
        (ok true)
    )
)

(define-public (file-dispute (land-id uint) (defendant principal))
    (let
        (
            (dispute-id (var-get next-dispute-id))
            (current-block stacks-block-height)
        )
        (asserts! (is-some (map-get? lands { land-id: land-id })) err-not-found)
        (map-set disputes
            { dispute-id: dispute-id }
            {
                land-id: land-id,
                complainant: tx-sender,
                defendant: defendant,
                status: "pending",
                filed-at: current-block,
                resolved-at: none
            }
        )
        (var-set next-dispute-id (+ dispute-id u1))
        (ok dispute-id)
    )
)

(define-public (resolve-dispute (dispute-id uint) (resolution (string-ascii 20)))
    (let
        (
            (dispute-data (unwrap! (map-get? disputes { dispute-id: dispute-id }) err-not-found))
            (current-block stacks-block-height)
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set disputes
            { dispute-id: dispute-id }
            (merge dispute-data {
                status: resolution,
                resolved-at: (some current-block)
            })
        )
        (ok true)
    )
)

(define-read-only (get-land (land-id uint))
    (map-get? lands { land-id: land-id })
)

(define-read-only (get-land-owner (land-id uint))
    (match (map-get? lands { land-id: land-id })
        land-data (ok (get owner land-data))
        err-not-found
    )
)

(define-read-only (get-usage-rights (land-id uint) (user principal))
    (map-get? usage-rights { land-id: land-id, user: user })
)

(define-read-only (is-usage-rights-valid (land-id uint) (user principal))
    (match (map-get? usage-rights { land-id: land-id, user: user })
        rights-data (ok (< stacks-block-height (get end-block rights-data)))
        (ok false)
    )
)

(define-read-only (get-land-history (land-id uint) (transaction-id uint))
    (map-get? land-history { land-id: land-id, transaction-id: transaction-id })
)

(define-read-only (get-dispute (dispute-id uint))
    (map-get? disputes { dispute-id: dispute-id })
)

(define-read-only (get-transaction-count (land-id uint))
    (get transaction-count (default-to { transaction-count: u0 } (map-get? land-transactions { land-id: land-id })))
)

(define-read-only (has-pending-dispute (land-id uint))
    (let
        (
            (dispute-check (fold check-dispute-status (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) { land-id: land-id, has-pending: false }))
        )
        (get has-pending dispute-check)
    )
)

(define-private (check-dispute-status (dispute-id uint) (acc { land-id: uint, has-pending: bool }))
    (if (get has-pending acc)
        acc
        (match (map-get? disputes { dispute-id: dispute-id })
            dispute-data 
                (if (and (is-eq (get land-id dispute-data) (get land-id acc))
                        (is-eq (get status dispute-data) "pending"))
                    (merge acc { has-pending: true })
                    acc
                )
            acc
        )
    )
)

(define-read-only (get-total-value-by-owner (owner principal))
    (let
        (
            (land-values (fold sum-owner-land-values (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20) { owner: owner, total-value: u0 }))
        )
        (get total-value land-values)
    )
)

(define-private (sum-owner-land-values (land-id uint) (acc { owner: principal, total-value: uint }))
    (match (map-get? lands { land-id: land-id })
        land-data 
            (if (is-eq (get owner land-data) (get owner acc))
                (merge acc { total-value: (+ (get total-value acc) (get value land-data)) })
                acc
            )
        acc
    )
)

(define-read-only (get-land-count-by-owner (owner principal))
    (let
        (
            (land-count (fold count-owner-lands (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20) { owner: owner, count: u0 }))
        )
        (get count land-count)
    )
)

(define-private (count-owner-lands (land-id uint) (acc { owner: principal, count: uint }))
    (match (map-get? lands { land-id: land-id })
        land-data 
            (if (is-eq (get owner land-data) (get owner acc))
                (merge acc { count: (+ (get count acc) u1) })
                acc
            )
        acc
    )
)
