import SwiftUI
import AVFoundation
import Combine
import CoreLocation
import CoreHaptics


// This section of the code is the beacon detection system, it determins the location and distance
class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Create context managers
    var locationManager: CLLocationManager?
    @Published var lastDistance = CLProximity.unknown
    @Published var noise = -100
    
    // Initilizer, override and create CLLocationManagers
    override init(){
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
    
    // This is the location manager that grabs the id and starts scanning if device permits location data
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways{
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable(){
                    startScanning(m: 0)
                }
            }
        }
    }
    
    // Function to start scanning for beacon devices
    func startScanning(m: UInt16){
        let uuid = UUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: m, minor: 0)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    // Location manager to allow location access and determine area
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first{
            update(distance: beacon.proximity, noise: beacon)
        } else{
            update(distance: .unknown, noise: nil)
        }
    }
    
    // Update the function and emit noise rssi data and distance data
    func update(distance: CLProximity, noise: CLBeacon?) {
        lastDistance = distance
        if (noise != nil){
            self.noise = noise!.rssi
        }
    }
}

// Unified modifier so the text data is aligned
struct BigText: ViewModifier{
    func body(content: Content) -> some View{
        content
            .font(Font.system(size: 36, design: .rounded))
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                   minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    }
}

// View main frame, everything is wired up here
struct ContentView: View {
    // Create private variables for haptic custom engine feedback and beacon detection
    @State private var engine: CHHapticEngine?
    @ObservedObject var detector = BeaconDetector()
    
    // This function prepares the haptic feedback sensors
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    // Complex custom haptic feedback feature to notify users of incoming buses
    func complexSuccess(intensity: Int) {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        // 0.15, 0.1, 0.01
        switch intensity{
        case 1:
            for i in stride(from: 0, to: 3, by: 0.2) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                events.append(event)
            }
        case 2:
            for i in stride(from: 0, to: 1, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                events.append(event)
            }
            for i in stride(from: 0, to: 1, by: 0.15) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1+i)
                events.append(event)
            }
        case 3:
            for i in stride(from: 0, to: 0.5, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(Double(1 - i) - Double(detector.noise) / -60.0))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                events.append(event)
            }
            for i in stride(from: 0.5, to: 1, by: 0.2) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                events.append(event)
            }
        case 4:
            for i in stride(from: 0, to: 1, by: 0.01) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                events.append(event)
            }
        default:
            for i in stride(from: 0, to: 3, by: 0.15) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
                events.append(event)
            }
        }

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    
    // Bus section
    
    @State private var status: CLProximity = .unknown

    var body: some View {
        Text(detector.lastDistance.text)
            .modifier(BigText())
            .onAppear(perform: prepareHaptics)
            .background(detector.lastDistance.color)
            .onTapGesture {
                busStatus(text: detector.lastDistance.spoken)
                complexSuccess(intensity: detector.lastDistance.intensity)
            }
            .onChange(of: detector.lastDistance) {
                busStatus(text: $0.spoken)
                complexSuccess(intensity: detector.lastDistance.intensity)
            }
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Create post request, and then determine which bus is near
func busStatus(text: String) {
    let url = URL(string: "http://47.242.92.68:5000/")
    guard let requestUrl = url else { fatalError() }
    // Prepare URL Request Object
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
     
    // HTTP Request Parameters which will be sent in HTTP Request Body
    let postString = "data=2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6";
    // Set HTTP Request Body
    request.httpBody = postString.data(using: String.Encoding.utf8);
    // Perform HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            // Convert HTTP Response Data to a String
            let result = String(data: data!, encoding: .utf8)
            print(result!)
            var utterance = AVSpeechUtterance()
            if (text == "检测到公交车。" || text == "附近没有公交。"){
                utterance = AVSpeechUtterance(string: text )
            } else {
                utterance = AVSpeechUtterance(string: result! + text)
            }
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
            utterance.rate = 0.52

            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
    }
    task.resume()
}

// Extension to allow proximity enumeration
extension CLProximity {

  var text: String {
    switch self {
      case .immediate:
        return "公交就在面前。"
      case .near:
        return "公交已经靠近。"
      case .far:
        return "检测到公交车。"
      default:
        return "附近没有公交。"
    }
  }

    var spoken: String {
        switch self {
            case .immediate:
                return "号公交就在面前。"
            case .near:
                return "号公交已经靠近。"
            case .far:
                return "检测到公交车。"
            default:
                return "附近没有公交。"
        }
    }

    var color: Color {
        switch self {
            case .far:
                return .yellow
            case .near:
                return .blue
            case .immediate:
                return .green
            default:
                return .red
        }
    }

    var intensity: Int {
        switch self {
            case .immediate:
                return 4
            case .near:
                return 3
            case .far:
                return 2
            default:
                return 1
        }
    }
}
