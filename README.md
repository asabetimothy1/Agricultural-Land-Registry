# 🌾 Agricultural Land Registry (LandLedger)

An immutable blockchain registry for land ownership and usage rights, simplifying transactions and resolving disputes on the Stacks network.

## 📋 Overview

LandLedger is a smart contract that provides a secure, transparent, and immutable system for:
- 📝 Land registration and ownership tracking
- 🔄 Secure land transfers
- 👥 Usage rights management
- ⚖️ Dispute resolution
- 📊 Transaction history

## ✨ Features

- **🏠 Land Registration**: Register new land parcels with location, size, type, and value
- **🔐 Ownership Management**: Transfer land ownership with complete transaction history
- **📜 Usage Rights**: Grant and manage temporary usage rights to other parties
- **⚖️ Dispute System**: File and resolve land disputes through the contract
- **📈 Value Updates**: Update land valuations as market conditions change
- **🔍 Query Functions**: Read land data, ownership, and transaction history

## 🚀 Quick Start

### Prerequisites
- Clarinet installed
- Stacks wallet for testing

### Installation
```bash
git clone <repository-url>
cd Agricultural-Land-Registry
clarinet check
```

## 📖 Usage

### Register New Land
```clarity
(contract-call? .LandLedger register-land 
    "123 Farm Road, County ABC" 
    u100 
    "agricultural" 
    u50000)
```

### Transfer Land Ownership
```clarity
(contract-call? .LandLedger transfer-land 
    u1 
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Grant Usage Rights
```clarity
(contract-call? .LandLedger grant-usage-rights 
    u1 
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
    "farming" 
    u1000 
    "Seasonal farming rights for corn cultivation")
```

### Update Land Value
```clarity
(contract-call? .LandLedger update-land-value u1 u55000)
```

### File a Dispute
```clarity
(contract-call? .LandLedger file-dispute 
    u1 
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

## 🔍 Query Functions

### Get Land Information
```clarity
(contract-call? .LandLedger get-land u1)
```

### Check Land Owner
```clarity
(contract-call? .LandLedger get-land-owner u1)
```

### View Usage Rights
```clarity
(contract-call? .LandLedger get-usage-rights 
    u1 
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Get Transaction History
```clarity
(contract-call? .LandLedger get-land-history u1 u0)
```

## 🏗️ Contract Structure

### Data Maps
- `lands`: Core land information and ownership
- `land-history`: Complete transaction history
- `usage-rights`: Temporary usage permissions
- `disputes`: Dispute tracking and resolution
- `land-transactions`: Transaction counters

### Error Codes
- `u100`: Owner only operation
- `u101`: Land not found
- `u102`: Already exists
- `u103`: Unauthorized access
- `u104`: Invalid transfer
- `u105`: Pending dispute blocks action

## 🧪 Testing

Run the test suite:
```bash
clarinet test
```

## 🔒 Security Features

- ✅ Owner-only functions for sensitive operations
- ✅ Dispute system prevents transfers during conflicts
- ✅ Immutable transaction history
- ✅ Usage rights expiration system
- ✅ Authorization checks on all operations

## 📊 Contract Statistics

- **Contract Size**: ~200 lines of Clarity code
- **Gas Optimized**: Efficient data structures and operations
- **Scalable**: Supports unlimited land parcels and transactions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `clarinet check` to verify
5. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

---

**Built with ❤️ for transparent land management on Stacks blockchain**
