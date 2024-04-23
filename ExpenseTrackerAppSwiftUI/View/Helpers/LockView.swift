//
//  LockView.swift
//  LockViewSwiftUI
//
//  Created by Hakob Ghlijyan on 17.04.2024.
//

import SwiftUI
import LocalAuthentication

// Custom View
struct LockView<Content: View>: View {
    //Lock Properies
    var lockType: LockType
    var lockPin: String
    var isEnabled: Bool
    var lockWhenAppGoesBackground: Bool = true
    @ViewBuilder var content: Content
    var forgotPin: () -> () = { }
    //View Properies
    @State private var pin: String = ""
    @State private var animateField: Bool = false
    @State private var isUnlocked: Bool = false
    @State private var noBiometricAcceses: Bool = false
    //Lock Context , for enable faceid
    let context = LAContext()
    // Scene Phase
    @Environment(\.scenePhase) private var scenePhase
        
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            content
                .frame(width: size.width, height: size.height)
            
            if isEnabled && !isUnlocked {
                ZStack {
                    Rectangle().fill(.black).ignoresSafeArea()

                    if (lockType == .both && !noBiometricAcceses) || lockType == .biometric {
                        Group {
                            if noBiometricAcceses {
                                Text("Enable biometric authentication on Settings to unlock the view!")
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(50)
                            } else {
                                // Bio Metric / Pin Unlock
                                VStack(spacing: 12.0) {
                                    //1
                                    VStack(spacing: 6.0) {
                                        Image(systemName: "faceid")
                                            .font(.largeTitle)
                                        Text("Tap to Unlock")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        unlockView()
                                    }
                                    //2
                                    if lockType == .both {
                                        Text("Entre Pin")
                                            .frame(width: 100, height: 40)
                                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                noBiometricAcceses = true
                                            }
                                    }
                                }
                            }
                        }
                    } else {
                        NumberPadPinView()
                    }
                }
                .environment(\.colorScheme, .dark)
                .transition(.offset(y: size.height + 100))
            }
        }
        .onChange(of: isEnabled, initial: true) { oldValue, newValue in
            if newValue {
                unlockView()
            }
        }
        // Locking When App Goes BackGround
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue != .active && lockWhenAppGoesBackground {
                isUnlocked = false
                pin = ""
            }
            if newValue == .active && !isUnlocked && isEnabled {
                unlockView()
            }
        }
    }
    
    private func unlockView() {
        // Checking and Unlocking View
        Task {
            if isBiometricAvailable && lockType != .number {
                // Requesting Biometric Unlock
                if let result = try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the View"),
                   result {
                    print("Unlocked")
                    withAnimation(.snappy, completionCriteria: .logicallyComplete) {
                        isUnlocked = true 
                    } completion: {
                        pin = ""
                    }
                }
            }
            // No BioMetric Permission || Lock type Must be Set KeyPad
            // Updating Biometric Status
            noBiometricAcceses = !isBiometricAvailable
        }
    }
    
    private var isBiometricAvailable: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    @ViewBuilder
    private func NumberPadPinView() -> some View {
        VStack(spacing: 15.0) {
            Text("Entre Pin Code")
                .font(.title.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    if lockType == .both && isBiometricAvailable {
                        Button(action: {
                            pin = ""
                            noBiometricAcceses = false
                        }, label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .contentShape(.rect)
                        })
                        .tint(.white)
                        .padding(.leading)
                    }
                }
            
            HStack(spacing: 10.0) {
                ForEach(0 ..< 4) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 55)
                    //Show pin , number
                        .overlay {
                            //Save check
                            if pin.count > index {
                                let index = pin.index(pin.startIndex, offsetBy: index)
                                let string = String(pin[index])
                                
                                Text(string)
                                    .font(.title.bold())
                                    .foregroundStyle(.black)
                            }
                        }
                }
            }
            //Add animation for wronge password eith keyframe animator
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: animateField, content: { content, value in
                content.offset(x: value)
            }, keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(30, duration: 0.07)
                    CubicKeyframe(-30, duration: 0.07)
                    CubicKeyframe(20, duration: 0.07)
                    CubicKeyframe(-20, duration: 0.07)
                    CubicKeyframe(0, duration: 0.07)
                }
            })
            .padding(.top, 15)
            .overlay(alignment: .bottomTrailing, content: {
                Button("Forgot Pin?", action: forgotPin)
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .offset(y: 40)
            })
            .frame(maxHeight: .infinity)
            
            // Custom Number Pad
            GeometryReader(content: { geometry in
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), content: {
                    ForEach(1...9, id: \.self) { number in
                        Button(action: {
                            // Adding Number to Pin
                            // Max Limit - 4
                            if pin.count < 4 {
                                pin.append("\(number)")
                            }
                        
                        }, label: {
                            Text("\(number)")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(.gray.opacity(0.2))
                                .contentShape(.rect)
                        })
                        .tint(.white)
                        .clipShape(Circle())
                    }
                    
                    Button(action: {
                        if !pin.isEmpty {
                            pin.removeLast()
                        }
                    }, label: {
                        Image(systemName: "delete.backward")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(.gray.opacity(0.2))
                            .contentShape(.rect)
                    })
                    .tint(.white)
                    .clipShape(Circle())
                    
                    Button(action: {
                        if pin.count < 4 {
                            pin.append("0")
                        }
                    }, label: {
                        Text("0")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(.gray.opacity(0.2))
                            .contentShape(.rect)
                    })
                    .tint(.white)
                    .clipShape(Circle())
                    
                })
                .frame(maxHeight: .infinity, alignment: .bottom)
            })
            .onChange(of: pin) { oldValue, newValue in
                if newValue.count == 4 {
                    // Valid Pin
                    if lockPin == pin {
                        withAnimation(.snappy, completionCriteria: .logicallyComplete) {
                            isUnlocked = true
                        } completion: {
                            pin = ""
                            noBiometricAcceses = !isBiometricAvailable
                        }
                    } else {
                        pin = ""
                        animateField.toggle()
                    }
                }
            }
            
        }
        .padding()
        .environment(\.colorScheme, .dark)
    }
    
    //LockType
    enum LockType: String {
        case biometric = "Bio Metric Auth"
        case number = "Custom Number Lock"
        case both = "First preference will be biometric, and if it's not available, it will go for number lock."
    }
}

#Preview {
    ContentView()
}
