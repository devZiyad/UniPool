# UniPool

UniPool is a carpooling application designed exclusively for university students to share rides safely, conveniently, and affordably within their campus community.

Kanban Board: https://trello.com/invite/b/68fce5588559a96c8bb57a4d/ATTI70741969f7daa0f7319562d4f276b8da75F9874B/swen-kanban-board 

## Features

### Functional requirements: 

  

User management: 

The system shall allow users to register using their university credentials.  

The system shall verify users as valid university students before giving access to the app.  

The system shall allow users to choose their role after registration (the role could be rider or driver).  

Ride management: 

The system must provide posting the driver’s ride, its details (destination, date, time, and number of empty seats). 

The system must allow drivers to have access to modify or update their posted rides. 

The system will reduce the number of available seats after a successful booking. 

The system shall automatically calculate the price in the system per distance and ride time.  

Ride search and matching: 

The system shall allow user to see the closest rider who is in their proximity area of influence. 

The system shall provide users with a search facility to find available rides by destination, time, date, and location. 

The system shall allow users to view the ride details before booking.  

Booking and payment:  

The system shall allow users to book a ride and reserve a seat in the ride.  

The system shall allow users to view a booking summary.  

The system shall support secure payment methods and allow users to split the ride costs with other riders within the same ride.  

Notification and tracking:  

The system shall allow users to view their riders’ or drivers’ real-time location.  

The system shall send ride reminders to the users, whether it is the rider and driver, including notification of booking confirmation and cancellation.  

Feedback and rating: 

The system shall allow the user to rate the rider after the ride is completed.  

The system shall store feedback to maintain driver and rider reliability matrices.  

  

### Non-functional requirements:  

Performance: 

The systems shall respond within seconds after the user chooses actions. 

Security: 

The system shall support encryption and securely store all user data and payments.  

Usability: 

The system interface must be simple in a way that the user can interact with the system easily.  

Scalability: 

The system must be able to deal with new features that are added later on. 

Privacy:  

The system must not share users’ personal data, including location data, without consent.  

Notification efficiency: 

The system must send booking updates within seconds of an update/change. 

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

Jess: 
During the first sprint, I worked behind the design and analysis of UML diagram specifically for User class which is our primary class and Vehicle class which is an extension for driver class. In addition, me and Ziyad had our discussion on how to organize user stories into UML classes and how each class could be interrelated. We also discussed all possible functions and data structures we could implement based on our team's user stories. After continuous iterative planning, we designed three UML diagrams which explain the classes and their interrelationships in three possible ways. While Ziyad designed the UML diagrams, I monitored his steps ensuring that its properly aligned to our user stories. In addition to UML, I worked in designing the use case for payment method and cost-split method. 

The user stories that I mainly worked on are 1.1, 1.9, 1.10, & 1.13. Throughout the sprint I faced challenges during the phase of UML designing, where I should brainstorm, narrow down and organize functions and data structures into classes in a way that aligns with our user stories. Compared to UML, specific tasks like Use case diagrams felt much easier to visualize and design. In the Upcoming sprint, I would monitor and analyze the effectiveness of integrating backend and databases without affecting the basic structure but building upon it.

To conclude : Things I mainly worked on: Created User & Vehicle class,`Organization & Design of UML, reshaping UML based on User stories, Designing Use-Case diagrams for payment

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



_____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________

Sprint 2: 

![alt text](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-11-24%20082159.png)

Complete Table with Tasks: 
![alt text](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-11-26%20094824.png)

Ziyad: 
Pervious Design of UML Class Component Diagram
![uml class diagram](https://github.com/devZiyad/UniPool/blob/main/UML%20Class%20Diagram.png)

Jess (Scrum Master(also stood as Developer)):
https://aubh-my.sharepoint.com/:w:/g/personal/f2300044_aubh_edu_bh/IQCw40F03E5zQZlCl2HOobtbAbpa0lD8cpJB9bKGUQ2FKJE?e=MdTByF
Responsibly did my work as a scrum master while developing meeting minutes, Standups, Sprint ceremonies , Burn down chart , Impediment log , velocity graph 

Lana: 
In sprint 2 I completed the comparison matrix between the Layered and MVC architecture approach. First, I completed the comparison between the 2 in terms of Scalability, Security, Maintainability, Team fit and support for uniPool’s needs.  

![Compare](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-11-26%20100343.png)


Then created the decision matrix between the 2 approaches.  

![Decision matrix](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-11-26%20100357.png)

The weights were determined based on the importance of each criterion to the uniPool system’s goals and requirements.  
- Scalability (Weight = 5): 
UniPool is expected to grow significantly—more users, advanced ride matching, real-time tracking, and future features. Scalability is critical for long-term success, so it received the highest weight. 
- Security (Weight = 4): 
The system handles sensitive data like university IDs, location, and payment details. Strong security is essential, so it was given a high weight, just slightly below scalability. 
- Maintainability (Weight = 3): 
The system will evolve with new features and bug fixes. While important, it’s less critical than scalability and security for initial success, so it has a moderate weight. 
- Team Fit (Weight = 2): 
Team familiarity and ease of collaboration matter, but skills can improve over time. Therefore, this criterion has the lowest weight.

The UML Components 
User: 

![user](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-11-26%20192742.png)

The UML Components 
Location:

![user](https://github.com/devZiyad/UniPool/blob/main/Screenshot%202025-11-26%20192759.png)

In ethical design statement I pushed for  a design where location visibility is enabled only during the pickup and ride period and automatically disabled afterward, reducing the risk of exposing users to intrusion or misuse of personal data. 

Meshal : 
In Sprint 2 worked on Mapping design pattern and Rating UML Diagram Component .


<img width="346" height="403" alt="Picture1" src="https://github.com/user-attachments/assets/ad4f4389-2649-4a62-b323-f513dc11c21e" />
<img width="334" height="402" alt="Picture2" src="https://github.com/user-attachments/assets/46fc6ede-f5c4-4f3e-83da-dca91578de2d" />
<img width="624" height="440" alt="Picture3" src="https://github.com/user-attachments/assets/d0c7f50c-0172-496f-8e00-1bdd6c63c588" />

---
Lulwa: 
In Sprint 2, I was mainly involved in enhancing the system structure and moral principles underlying UniPool. I spent time on the refinement of the Data Flow Model, so that the flow of user authentication, ride posting, and booking and location tracking was achieved in accordance with our intended components and the Non-Functional Requirements. I also made a contribution to the Ethical Design Statement as well, but in this case, I decided to influence the safety section as I suggested that the riders and drivers need to cancel the ride anytime and that emergency alerts need to be integrated into the design as a fundamental element to secure the users when interacting with each other physically. My contributions empowered the team to make decisions regarding safety, privacy, and real-time tracking rules. I also took active part in the Sprint 2 ceremonies, writing down the major points of discussion in the meeting minutes, and the team needed to stay on track and hold to the right direction when narrowing down features. In general, my sprint work facilitated the technical organization of the system and ethical principles according to which it was created.

Ethical Design Statement: 

The UniPool team will strive to ensure that it creates a university carpool and ride-sharing app that upholds responsible engineering, that protects users. Ethics directs all decision-making in the system design, including data manipulation to matching algorithms, and protection features. The following principles describe our commitments.  

Privacy (Location/Data Handling) 

UniPool works with sensitive personal information of students such as identity, profile photos, and live GPS position. All storage entries of personal and location data are encrypted and only disclosed when necessary to do core ride-matching. Location visibility is also strictly controlled to pick up and active-ride duration, then automatically disabled to avoid excessive tracking. The access to the platform is limited to verified AUBH credentials; only valid users can be involved, and no information is transferred to third parties. Sprint 1 reliability issues and GPS-related security risks will be overcome with the help of a design change: the transition to secure cloud infrastructure, in this case, AWS, that will enhance data security and stability of the whole system. A small, controlled group of users will be used to conduct initial QA/QC beta testing to determine the existence of privacy or reliability defects before it is fully deployed. 

Fairness (Matching Algorithm) 

UniPool guarantees that all the riders and drivers are treated equally. The matching algorithm does not involve any gender, nationality, looks, or other personal characteristics in the decision. There is no subjective approach to matches: the fact is that they are determined only by objective criteria: similarity of routes, time, and availability of seats, and professed preferences. The two-way rating system with a clear degree of transparency ensures that the bias is minimized, and accountability is achieved, so that each user has an equal chance to either request or offer rides. 

Safety (Emergency Features) 

Since UniPool requires actual physical interactions, the safety of the users is a fundamental ethical necessity. ID check helps avoid the creation of fake accounts, and live ride tracking, which enables students to share their current position with trusted people. In-built alarm buttons and alerts facilitate quick actions in hazardous events, which will be postponed for later in sprint 3. User autonomy and personal protection are supported by riders and drivers being able to cancel their rides at any time and ensure personal safety. 

Ethical Trade-Off: Privacy vs. Convenience 

UniPool has to find a balance between effective coordination with the right of the user to privacy. Although the use of accurate GPS enhances the speed of matching and minimizes the waiting time, over exposure poses the risk of privacy. The system thus enables the live tracking only at vital stages of the ride not before or after. Since the features like posting rides, booking rides, and GPS tracking are essential safety and convenience features, they simply cannot be pushed to subsequent sprints. Delaying such features, under the principle of Cost of Quality, would exponentially increase the cost and disruptiveness of fixing defects. These functions are presented as the main interactions of the Sequence and Component Diagrams. This is a moderate solution that does not violate privacy at the expense of functionality and safety. 


Ethical Commitment  

With such values combined in our design and development process, the UniPool team can ensure that it has the ability to use the application to serve in ensuring a safe, fair, and trustworthy ride-sharing community for all university students. Our team will provide a constant review of these principles as the system changes. 

___________________________________________________________________________________________________________________________________________________________________________________
User Documentation: “How to use?”  

Account Creation 
You have two options in the Welcome screen to choose from, Login (if you already have an account) and Register (to create a new account). 

Choosing “login” transfer you to the “login” page where you will be required to choose to log in as Driver or a Rider.  

Either you choose to log in as Driver or log in as Rider you will have to put your email and password and if they are correct and there is a matching account you will log in to it. 

Choosing “Register” will transfer you to the “Register” page where you will be able to create an account. First, you will need to put your name, email and password, then choose to register as a “rider” or “driver”.  

After you’re done, press on sign up to move to the next page.  

In this page you will be required to input a few photos. 

Input a photo of your university card.  

Input a photo of your ID card.  

If you signed up as a Driver, Input a photo of Your driver’s license. After inputting  the required information, your account is ready. 

Driver experience 
As you log in as a driver, you will be able to post a ride in drive posting page, where you will be required to enter the following information: 

First, as a driver you need to choose your “Source location” by your current live location or a location of your desire. 

Second, you need to choose your destination.  

Third, you need to choose the time you will be on the road (Starting time and ending time). 

Fourth, you will be able to view your available seats based on your input.  

Lastly, confirm the drive and it will be posted for users looking for a ride. 

After your ride is chosen by a rider, you will have the option to accept or deny the request and see the information about the ride. 
Information such as:  
   - Ride request  
   - Number of seats chosen 

   - The rider’s distance away from you (in both time and kilometers) 

If the ride was accepted, the number of available seats for your car would update and you will be able to see the live location of the rider and the time of arrival.  

Once reaching the rider’s location, you will have to confirm the ride to start.  

After the ride is completed, you will get the option to rate the driver out of 5 stars and provide feedback in a comment section.  

Rider experience 

After you logged in as a rider, you will be transferred to the rider's home where you can choose a ride for the location you're going to. 

First, as a user you will need to choose your “pick up” location it can be either your current live location or a location of your desire.  

Second, as a user, you need to choose your destination.   

Third, you will get the option to choose the time you need to get picked up from the “pick up” location, you also can choose to get “picked up now”.  

Fourth, you will be required to choose the number of seats you will need.  

After you’ve chosen the time and location and number of seats you’ll be transferred to the Ride List where you’ll be able to request a ride out of available drivers and their information  
information include : 
   - Driver’s name 
   - Driver’s rating 
   - Fee (calculated based on the distance) 
   - Driver’s distance away from you (in both time and Kilometers) 
   - Available seats 

After pressing “request” you will have to wait for the driver to confirm your request or deny it.  

If your request was accepted, you will be able to see the driver's real time location and their time of arrival. Also you will have the ability to choose your payment method, contact the driver, and cancel the ride if you want. 

After you reach the destination and the ride is concluded, you will have the option to rate your driver out of five stars and provide feedback in a comment section. 



