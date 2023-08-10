//
//  AnimationTransitionView.swift
//  Landmarks
//

import SwiftUI
import Water

// FIXME:
// 1. environment rerender many times problem
// 2. add effect scope
// 3. begin animation not same

func HikeView(hike: Hike) -> some View {
    let showDetail = defValue(false)
    
    return View {
        VStack {
            HStack {
                HikeGraph(hike: hike, path: \.elevation) // FIXME: - if contains a view with state, need effect scope support - nested effect support
                    .frame(width: 50, height: 30)

                VStack(alignment: .leading) {
                    Text(hike.name)
                        .font(.headline)
                    Text(hike.distanceText)
                }
                Spacer()
                Button {
                    withAnimation {
                        showDetail.value.toggle()
                    }
                } label: {
                    Label("Graph", systemImage: "chevron.right.circle")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .rotationEffect(.degrees(showDetail.value ? 90 : 0))
                        .scaleEffect(showDetail.value ? 1.5 : 1)
                        .padding()
                }
            }
            if showDetail.value {
                HikeDetail(hike: hike)
                    .transition(.moveAndFade)
            }
        }
    }
}

func HikeDetail(hike: Hike) -> some View {
    let buttons = [
        ("Elevation", \Hike.Observation.elevation),
        ("Heart Rate", \Hike.Observation.heartRate),
        ("Pace", \Hike.Observation.pace)
    ]
    
    let dataToShow = defReactive(buttons[0].1) // FIXME: - this not call effect, effect need generate with container view
    
    return View {
        VStack {
            HikeGraph(hike: hike, path: dataToShow.unwrap())
                .frame(height: 200)
            HStack(spacing: 25) {
                ForEach(buttons, id: \.0) { value in
                    Button {
                        dataToShow.target = value.1
                    } label: {
                        Text(value.0)
                            .font(.system(size: 15))
                            .foregroundColor(value.1 == dataToShow.target
                                ? .gray
                                : .accentColor)
                            .animation(nil)
                    }
                }
            }
        }
    }
}

// FIXME: - add memo
func HikeGraph(hike: Hike, path: KeyPath<Hike.Observation, Range<Double>>) -> some View {
    var color: Color {
        switch path {
        case \.elevation:
            return .gray
        case \.heartRate:
            return Color(hue: 0, saturation: 0.5, brightness: 0.7)
        case \.pace:
            return Color(hue: 0.7, saturation: 0.4, brightness: 0.7)
        default:
            return .black
        }
    }
    
    let data = hike.observations
    let overallRange = rangeOfRanges(data.lazy.map { $0[keyPath: path] })
    let maxMagnitude = data.map { magnitude(of: $0[keyPath: path]) }.max()!
    let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))
    
    return GeometryReader { proxy in
        HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, observation in
                GraphCapsule(
                    index: index,
                    color: color,
                    height: proxy.size.height,
                    range: observation[keyPath: path],
                    overallRange: overallRange
                )
                .animation(.ripple(index: index))
            }
            .offset(x: 0, y: proxy.size.height * heightRatio)
        }
    }
}

func GraphCapsule(index: Int, color: Color, height: CGFloat, range: Range<Double>, overallRange: Range<Double>) -> some View{
    var heightRatio: CGFloat {
        max(CGFloat(magnitude(of: range) / magnitude(of: overallRange)), 0.15)
    }

    var offsetRatio: CGFloat {
        CGFloat((range.lowerBound - overallRange.lowerBound) / magnitude(of: overallRange))
    }

    return View {
        Capsule()
            .fill(color)
            .frame(height: height * heightRatio)
            .offset(x: 0, y: height * -offsetRatio)
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
}

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}

struct HikeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HikeView(hike: hikes[0])
                .padding()
            Spacer()
        }
    }
}

// MARK: - Utils

func rangeOfRanges<C: Collection>(_ ranges: C) -> Range<Double>
    where C.Element == Range<Double> {
    guard !ranges.isEmpty else { return 0..<0 }
    let low = ranges.lazy.map { $0.lowerBound }.min()!
    let high = ranges.lazy.map { $0.upperBound }.max()!
    return low..<high
}

func magnitude(of range: Range<Double>) -> Double {
    range.upperBound - range.lowerBound
}
