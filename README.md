# Roadie  
**AI Road Companion for Learning**  

Roadie is a hands-on learning project that brings AI and computer vision to the road.  
It runs on a Raspberry Pi 5 connected to a camera and small display, making it a complete platform to explore how AI can detect and display road information in real time.  

## 📋 Project Specification  

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
--image-- (Later)

### Layout  
- **Front page**: warnings (2/3), quick access buttons (1/3)  
- **Quick access buttons**:  
  - Button 1: Register control & switch  
  - Button 2: Menu  


# GUI functions
--image-- (Later)