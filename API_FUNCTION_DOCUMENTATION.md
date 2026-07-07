# VenusCRM API Function Documentation

This document provides a comprehensive list of functions used by various forms in the VenusCRM application, including the request parameters and the structure of the responses received from each API hit.

---

## 1. Authentication & Security

### `getLogin`
*   **Purpose**: Authenticates the user and retrieves user preferences and authority.
*   **Used by**: `LoginActivity`, `LoginFragment`
*   **Parameters**:
    *   `sUser` (String): Username
    *   `sPwd` (String): Password
*   **Response Structure (`Login` object)**:
    *   `Pref1`: Business Code
    *   `Pref2`: Business Name
    *   `Pref3`: Username
    *   `Pref4`: Sales Code
    *   `Pref5`: Sales Name
    *   `Pref6`: Business Authority (Pipe-separated string of codes)
    *   `Pref7`: Business Name Authority (Pipe-separated string of names)
    *   `Pref8`: User Authority (Pipe-separated string)

### `uploadNewPassword`
*   **Purpose**: Updates the user's password.
*   **Used by**: `ChangePwdFragment`
*   **Parameters**:
    *   `prmUser` (String): Username
    *   `prmNewPassword` (String): New password
*   **Response Structure (`UploadStatus` object)**:
    *   `Status` (Boolean): True if successful.

---

## 2. Lead Management

### `getLead`
*   **Purpose**: Fetches a list of leads for selection.
*   **Used by**: `LeadFragment`, `ActivityFragment` (for AutoComplete)
*   **Parameters**: `prmBusCode`, `prmUserAuth`, `prmLike`
*   **Response Structure (`Lead` model - List Data)**:
    *   `Pref1`: Lead ID(s) (Pipe-separated)
    *   `Pref2`: Lead Name(s) (Pipe-separated)
    *   `Pref3`: Company Name(s) (Pipe-separated)

### `getDataLead` (Find/Detail)
*   **Purpose**: Retrieves detailed lead information for search/list views.
*   **Used by**: `ListTableLead`, `FindViewLeadFragment`
*   **Parameters**: `prmBusCode`, `prmUserAuth`, `prmType`, `prmValue`, `prmDate1`, `prmDate2`
*   **Response Structure (`DataLead` model - Multiple Records)**:
    Returns fields `Pref1` through `Pref21` (Each is a pipe-separated string representing a column):
    *   `Pref1`: Lead ID
    *   `Pref2`: Business Name
    *   `Pref3`: Customer Name
    *   `Pref4`: Company
    *   `Pref5`: Line of Business (LOB)
    *   `Pref6`: Sales Owner
    *   `Pref7`: Email
    *   `Pref8`: Phone
    *   `Pref9`: Fax
    *   `Pref10`: Mobile
    *   `Pref11`: Website
    *   `Pref12`: Lead Source
    *   `Pref13`: Lead Status
    *   `Pref14`: Number of Employees
    *   `Pref15`: Address
    *   `Pref16`: City
    *   `Pref17`: State
    *   `Pref18`: Zip Code
    *   `Pref19`: Country/Region
    *   `Pref20`: Description
    *   `Pref21`: Is Suspend (Boolean string)

### `postLead`
*   **Purpose**: Creates or updates a Lead record.
*   **Used by**: `LeadFragment`
*   **Parameters**: 22 parameters including Business Code, Name, Company, Email, Phone, Address, etc.
*   **Response Structure**:
    *   `Status` (Boolean): True if successful.

---

## 3. Account & Contact Management

### `getAccount`
*   **Purpose**: Fetches a list of accounts.
*   **Used by**: `ActivityFragment`, `PotentialFragment` (for AutoComplete)
*   **Parameters**: `prmBusCode`, `prmUserAuth`, `prmLike`, `prmFromMenu`
*   **Response Structure (`Account` model)**:
    *   `Code`: Account Code(s) (Pipe-separated)
    *   `Name`: Account Name(s) (Pipe-separated)

### `getContact`
*   **Purpose**: Fetches a list of contacts.
*   **Used by**: `ContactFragment`, `ActivityFragment`
*   **Parameters**: `prmBusCode`, `prmUserAuth`, `prmLike`
*   **Response Structure (`Contact` model)**:
    *   `Pref1`: Account ID(s) (Pipe-separated)
    *   `Pref2`: Account Name(s) (Pipe-separated)
    *   `Pref3`: Contact ID(s) (Pipe-separated)
    *   `Pref4`: Contact Name(s) (Pipe-separated)

### `getDataContact` (Find/Detail)
*   **Purpose**: Retrieves detailed contact information.
*   **Used by**: `FindViewContactFragment`
*   **Response Structure (`DataContact` model)**:
    *   `Pref1` to `Pref16` (Pipe-separated columns):
        *   `Pref1`: Contact ID, `Pref2`: Business Name, `Pref3`: Contact Name, `Pref4`: Account Name, `Pref5`: Position, `Pref6`: Owner, `Pref7`: Email, `Pref8`: Phone, `Pref9`: Mobile, `Pref10`: Division, `Pref11`: Email (Alt), `Pref12`: Birth Day, `Pref13`: Religion, `Pref14`: Lead Source, `Pref15`: Description, `Pref16`: Is Suspend.

### `postContact`
*   **Purpose**: Creates or updates a Contact record.
*   **Response Structure**: `Status` (Boolean)

---

## 4. Potential (Opportunity) Management

### `getPotential`
*   **Purpose**: Fetches a list of potentials.
*   **Response Structure (`Potential` model)**:
    *   `Pref1` (AccountID), `Pref2` (AccountName), `Pref3` (PotentialID), `Pref4` (PotentialName) - all pipe-separated.

### `getDataPotential` (Find/Detail)
*   **Purpose**: Retrieves detailed potential information.
*   **Used by**: `FindViewPotentialFragment`
*   **Response Structure (`DataPotential` model)**:
    *   `Pref1` to `Pref17` (Pipe-separated columns):
        *   `Pref1`: Potential ID, `Pref2`: Business Name, `Pref3`: Account Name, `Pref4`: Potential Name, `Pref5`: Closing Date, `Pref6`: Stage, `Pref7`: Probability, `Pref8`: Owner, `Pref9`: Amount, `Pref10`: Method, `Pref11`: Location, `Pref12`: Lead Source, `Pref13`: Description, `Pref14`: Is Suspend, `Pref15`: Account Code, `Pref16`: Contact List, `Pref17`: Stage History.

---

## 5. Activity Management

### `postActivity`
*   **Purpose**: Logs a new activity (Meeting, Call, Task).
*   **Response Structure**: `Status` (Boolean)

### `getDataActivity` (Find/Detail)
*   **Purpose**: Retrieves list of activities for reports or tables.
*   **Used by**: `ActivityFragment`, `FindViewActivityLeadAccountFragment`
*   **Response Structure (`DataActivity` model)**:
    *   `Pref1` to `Pref13` (Pipe-separated columns):
        *   `Pref1`: Task ID, `Pref2`: Task Type, `Pref3`: Linked Entity Name, `Pref4`: Linked Entity Sub-Name, `Pref5`: Subject, `Pref6`: Due Date, `Pref7`: Status, `Pref8`: Priority, `Pref9`: Description, `Pref10`: Business Name, `Pref11`: Sales Owner, `Pref12`: Activity Type, `Pref13`: Coordinate.

---

## 6. Master Data / Dropdown Loaders

| Function | Response Structure | Description |
| :--- | :--- | :--- |
| `getBusiness` | `Code`, `Name` (Pipe-sep) | Available business units. |
| `getSales` | `Pref1`, `Pref2`, `Pref3` (Pipe-sep) | Sales owners: Usernam, SalesCode, SalesName. |
| `getLeadSource` | `Code`, `Name` (Pipe-sep) | Sources like "Web", "Referral". |
| `getLeadStatus` | `Code`, `Name` (Pipe-sep) | Statuses like "New", "Qualified". |
| `getActivityType` | `Pref1`, `Pref2`, `Pref3` (Pipe-sep) | Type Code, Type Name, IsLocationRequired. |
| `getLOB` | `Code`, `Name` (Pipe-sep) | Line of Business categories. |
| `getStage` | `Code`, `Name` (Pipe-sep) | Opportunity stages. |
| `getPosition` | `Code`, `Name` (Pipe-sep) | Job positions. |
| `getMethodPotential`| `Code`, `Name` (Pipe-sep) | Potential methods. |

---

## 7. Versioning & System

### `getVersi`
*   **Purpose**: Checks the application version for updates.
*   **Response Structure (`Versi` object)**:
    *   `Versi` (String): Current version (e.g., "1/1.0").
