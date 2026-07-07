# VenusCRM Form Requirements Documentation

This document outlines the field requirements, input types, and data sources for all forms in the application.

---

## 1. Login Form
Used for user authentication.

| Field | Type | Data Source |
| :--- | :--- | :--- |
| Username | TextBox | User Input |
| Password | Password TextBox | User Input |
| Version Check | Label/Hidden | `getVersi()` |

---

## 2. Lead Form
Used for creating or editing leads.

| Field | Type | Data Source |
| :--- | :--- | :--- |
| Business | Dropdown | `getBusiness()` |
| Owner | AutoComplete | `getSales()` |
| Name (Customer) | TextBox | User Input |
| Company | TextBox | User Input |
| LOB | Dropdown | `getLOB()` |
| Lead Source | Dropdown | `getLeadSource()` |
| Lead Status | Dropdown | `getLeadStatus()` |
| Phone | TextBox (Phone) | User Input |
| Mobile | TextBox (Phone) | User Input |
| Fax | TextBox | User Input |
| Email | TextBox (Email) | User Input |
| Website | TextBox (URL) | User Input |
| No of Employee | TextBox (Number) | User Input |
| Address | Multi-line TextBox | User Input |
| City | TextBox | User Input |
| State | TextBox | User Input |
| ZIP Code | TextBox (5 digits) | User Input |
| Country / Region | TextBox | User Input |
| Description | Multi-line TextBox | User Input |
| Is Suspend | CheckBox | User Input |

---

## 3. Contact Form
Used for managing points of contact (PIC).

| Field | Type | Data Source |
| :--- | :--- | :--- |
| Business | Dropdown | `getBusiness()` |
| Account | AutoComplete | `getAccount()` |
| Owner | AutoComplete | `getSales()` |
| Name (PIC Name) | TextBox | User Input |
| Position | TextBox | User Input |
| Division | TextBox | User Input |
| Phone | TextBox (Phone) | User Input |
| Mobile | TextBox (Phone) | User Input |
| Email | TextBox (Email) | User Input |
| Website | TextBox (URL) | User Input |
| Birth Day | DatePicker | User Input |
| Assistant | TextBox | User Input |
| Assistant Phone | TextBox (Phone) | User Input |
| Lead Source | Dropdown | `getLeadSource()` |
| Description | Multi-line TextBox | User Input |
| Is Suspend | CheckBox | User Input |

---

## 4. Potential (Opportunity) Form
Used for sales opportunities. This form includes two dynamic tables.

### Main Fields
| Field | Type | Data Source |
| :--- | :--- | :--- |
| Business | Dropdown | `getBusiness()` |
| Account | AutoComplete | `getAccount()` |
| Owner | AutoComplete | `getSales()` |
| Name | TextBox | User Input |
| Amount | TextBox (Currency) | User Input |
| Closing Date | DatePicker | User Input |
| Method | Dropdown | `getMethodPotential()` |
| Location | TextBox | User Input |
| Description | Multi-line TextBox | User Input |
| Is Suspend | CheckBox | User Input |

### Dynamic Table: Stage History
| Sub-Field | Type | Data Source |
| :--- | :--- | :--- |
| Stage | Dropdown | `getStage()` |
| Start Date | DatePicker | User Input |
| Finish Date | DatePicker | User Input |
| Description | TextBox | User Input |

### Dynamic Table: Related Contacts
| Sub-Field | Type | Data Source |
| :--- | :--- | :--- |
| Contact Name | Dropdown | `getDataContact2()` (Filtered by Account) |
| Position | TextBox (Read-only) | Auto-filled from Contact |
| Division | TextBox (Read-only) | Auto-filled from Contact |
| Phone | TextBox (Read-only) | Auto-filled from Contact |
| Description | TextBox | User Input |

---

## 5. Activity Form
Used for logging interactions (Meetings, Calls, Tasks).

| Field | Type | Data Source |
| :--- | :--- | :--- |
| Business | Dropdown | `getBusiness()` |
| Type (Link To) | Dropdown | Static: `Lead`, `Account`, `Contact`, `Potential` |
| Linked Entity | AutoComplete | `getLead`, `getAccount`, `getContact`, or `getPotential` |
| Activity Type | Dropdown | `getActivityType()` |
| Subject | TextBox | User Input |
| Date & Time | DateTimePicker | User Input |
| Status | Dropdown | Static: `Planned`, `Held`, `Not Held` |
| Priority | Dropdown | Static: `High`, `Medium`, `Low` |
| Coordinate | TextBox | GPS / `FusedLocationProvider` |
| Address | TextBox | Reverse Geocode from Coordinates |
| Description | Multi-line TextBox | User Input |

---

## 6. Change Password Form

| Field | Type | Data Source |
| :--- | :--- | :--- |
| Current Password | Password TextBox | User Input |
| New Password | Password TextBox | User Input |
| Confirm Password | Password TextBox | User Input |
