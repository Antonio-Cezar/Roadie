# Roadie  
**AI Road Companion for Learning**  

Roadie is a hands-on learning project that brings AI and computer vision to the road.  
It runs on a Raspberry Pi 5 connected to a camera and small display, making it a complete platform to explore how AI can detect and display road information in real time.  


## Project Update
Completed Phases
1. Idea & Concept – defining the project goal and core purpose (AI detection on Raspberry Pi 5 with a display).

2. Architecture & System Modeling – drafting how the system will be structured, including detections, data sources and layout.

3. GUI Mockups / Wireframes – creating initial drawings and interface concepts to plan how the driver interacts with the system.


####
Current & Upcoming Phases:

4. GUI Development – building the first working interface on the Raspberry Pi 5 display.
####

5. Core Functions & AI Integration – connecting the camera feed, detection libraries, and algorithms for road alerts.

6. Testing & Debugging – validating detections (police, obstacles, road signs), improving performance, and fixing issues.

7. Extended Coding & Features – refining the interface, adding quick access buttons, logging, and info gathering sources (Google Maps, control data).

8. Optimization Phase – improving real-time performance, resource usage, and responsiveness on the Raspberry Pi 5.

9. Documentation & Learning Notes – writing guides, lessons learned, and setup instructions for others who want to replicate the project.



## Project Specification  

### Priorities of detection alerts  
The system will always display the highest-priority event currently detected.  
- **Priority 1**: Obstacles (animals, humans, road cracks)  
- **Priority 2**: Police control 
- **Priority 3**: Road signs

### Info Gathering  
These are the **sources of information** that Roadie uses either to display data on the GUI or to improve detection and decision-making:  
- **Google Maps** – provides map data and location context.  
- **Dashboard camera** – real-time video input for object detection.  
- **AI libraries** – models and frameworks used for detecting objects and signs.  
- **Politikontroller app** – integration for reading and writing police control data.  
- **Algorithm** – calculates the chance of being controlled based on driving and external factors.  

### Logs for Future Development  
- Camera detection logs


# GUI Mockup

### Layout  
- **Front page**: warnings (2/3), quick access buttons (1/3)  
- **Quick access buttons**:  
  - Button 1: Register control & switch  
  - Button 2: Menu  

![Main page](/System%20engineering/GUI%20Mockup/Screen%20layout-Main-page.jpg)



# GUI functions


![Button functions](/System%20engineering/GUI%20Mockup/Screen%20layout-Button%20functions.jpg)