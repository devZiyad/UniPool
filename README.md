# UniPool

UniPool is a carpooling application designed exclusively for university students to share rides safely, conveniently, and affordably within their campus community.

Kanban Board: https://trello.com/invite/b/68fce5588559a96c8bb57a4d/ATTI70741969f7daa0f7319562d4f276b8da75F9874B/swen-kanban-board 

## Features

### Basic Requirements

- **1.1** User registration and login with university verification (via email domain or student ID), and the ability to choose a role: Rider or Driver
- **1.2** Drivers can add ride postings by entering details such as source location, destination, date, time, and available seats
- **1.3** Riders can search for available rides based on their current location and desired destination
- **1.4** Riders can be matched with the nearest available driver for convenience
- **1.5** Riders can book rides to reserve seats and confirm their travel plans
- **1.6** The system automatically updates available seats after successful bookings
- **1.7** Real-time location tracking allows both riders and drivers to view each other's location for smoother coordination
- **1.8** Drivers can view and manage all listed rides, including upcoming and completed trips
- **1.9** The ride cost is automatically calculated by the system based on distance, time, and other factors
- **1.10** Riders have access to multiple payment methods for convenience and flexibility
- **1.11** After each completed ride, users can rate and provide feedback to maintain service quality and trust

### Additional Requirements

- **1.12** Riders receive notifications for booking confirmations, cancellations, or ride status updates
- **1.13** Riders can split the ride cost with friends for shared trips

---
Sprint 1: 

Tasks: https://aubh-my.sharepoint.com/:x:/g/personal/f2300042_aubh_edu_bh/EX7kJLI2CSpFlWhCrvqJ5IMBWyHqqn_nWtJDmsFFi4T0Nw?e=tWXgMH

### Members & Contributions

Lana: 

What I worked on:  
- Design use case: Register, verify, login, choose role 
- Design use case: Search rides, match driver 
 - Create UML for Rating class 
 - Create UML of payment class

I focused on all the tasks that needed to be completed rather than starting with the user stories. However, this issue was quickly resolved with clear expectations established that user stories needed to be completed first, followed by the other diagrams. I primarily worked on completing the “Design use case: Register, verify, login, choose role” (User Story 1.1) and “Design use case: Search rides, match drivers” (User Stories 1.3, 1.4), both of which are crucial for the core user functionality of the system. Additionally, I created the UML for the Rating class (User Story 1.11) and the UML for the Payment class (User Stories 1.9, 1.10, 1.13), ensuring accurate representation of class structures and relationships.
Use Case Diagram: https://www.canva.com/design/DAG2-uqMKC4/deotXj8ZvYZZUCAtbIa-uw/edit?utm_content=DAG2-uqMKC4&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton

The Payment Class:

![alt text](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-10-27%20134154.png)

The Rating Class:

![alt text](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-10-27%20135240.png) 

User Stories & Acceptence Criteria: 
https://aubh-my.sharepoint.com/:x:/g/personal/f2300042_aubh_edu_bh/EeBXGKtcCv5BqDXi_xNr7QYBmPrVSkncUu_cL2G2kEI2dg?e=6p2j0W 

Meeting Minutes & Daily Scrum: https://aubh-my.sharepoint.com/:w:/g/personal/f2300042_aubh_edu_bh/EYpsHn5786JPq5v_gPiUuAcBvjxAs2WRjFgbLoKEc69vXQ?e=Ef8evH

For the next sprint, I plan to take a more prominent role in the development aspect such as implementing the user login and designing how the system will interact with the information, including the database schema. 

---

Ziyad

**What I worked on:**  
- Design use case: Post ride, manage rides  

During this sprint, I focused on developing the **“Design use case: Post ride, manage rides”** (User Stories 1.2, 1.8), which forms the foundation for how drivers interact with the system to create and manage ride offers. This included defining user flows for posting new rides, editing ride details, and managing active or completed rides.

Additionally, I contributed to **team discussions and coordination**, ensuring that my work aligned with the login and search use cases developed by Lana, allowing for a cohesive user experience across different modules.

I also assisted with **refining the UML structures** and reviewed the design consistency between ride management and driver-related components.

For the next sprint, I plan to transition towards **backend implementation**, focusing on developing the database schema and logic to support ride posting, management, and driver matching.

---

Jess: We need to work on the uml diagram
Lulwa: We need to work on finalizing the assigmnent doocument.

Abdulla: Developing the Figma, which is a draft and guide of the UI will look like. Developing all the pages and figuring out a logical flow for the Mobile app, which will eventually decide the system architecture. Therefore I had to review the UML aswell if it made sense and had a logical flow that works with the planned flow of the app.


Figma Prototype: https://www.figma.com/design/aUsCFUyGGDVJVQKYUAtEgi/SWEN360?node-id=0-1&t=KrOTEi6aqajt424U-1 


Meshal ajaj: worked on user class and rider and also helped with figma and finlizing use-case diagram
<img width="545" height="397" alt="image" src="https://github.com/user-attachments/assets/7c791700-8c3b-4a48-a64e-868a03e1451b" />
<img width="567" height="285" alt="image" src="https://github.com/user-attachments/assets/ece9defc-4802-4731-b0e5-c90e5c57112f" />
<img width="492" height="263" alt="image" src="https://github.com/user-attachments/assets/0d347b83-825d-4d9c-91d2-1eefd510d1d5" />
https://aubh-my.sharepoint.com/:w:/g/personal/f2300160_aubh_edu_bh/ESUZzY9bpfhNnDqlRzUD2VcB8XR9R9wbbNxRpSYrt0u5tw?e=CtXaEg


Sprint Retrospective: ![alt text](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-10-27%20142732.png)

Possible Constraints for the Carpool-Sharing System that will be elaborated on in the next sprint. 
- Ride Modification: Drivers can only modify ride details up to a certain time before the ride starts (for example and hour before).  
- Feedback Timing: Feedback can only be submitted after the ride is marked as completed.  
- Location Accuracy: Real-time tracking is dependent on the availability and accuracy of GPS data. 
- Search: Ride search results are limited to a defined proximity range (e.g., within 10 km). 
- System Load: The system must handle peak usage times, including class start/end hours, without performance degradation. 
- Scalability Constraint: The system must support more users without needing major architectural changes.

  Burndown of Sprint 1:
  
  ![alt text](https://github.com/devZiyad/UniPool/blob/main/Burndown%20.png)




