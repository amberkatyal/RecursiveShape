//
//  ViewController.swift
//  LuxsoftTest
//
//  Created by Amber Katyal on 31/10/23.
//

import UIKit

final class RecursiveShapeView: UIView {
    
    private let count: Int
    
    init(count: Int) {
        self.count = count
        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setStrokeColor(UIColor.black.cgColor)
        
        drawPattern(rect: rect, context: context)
    }
    
    func drawPattern(rect: CGRect, context: CGContext) {
        if count == 0 {
            return
        }
        var containerRect = rect
        for i in 1...count {
            if i % 2 == 1 {
                containerRect = renderEquilateralTriangle(in: containerRect, in: context)
            } else {
                containerRect = renderSquare(in: containerRect, in: context)
            }
        }
    }
    
    // 1. Find the height for equilateral triangle in screen rect.
    // 2. Render the triangle.
    // 3. Generate the rect for square inside triangle.
    // 4. Render that rect as square.
    // 5. Go to step 1.
    
    func height(forEquilateralTriangleEdge edge: CGFloat) -> CGFloat {
        return (sqrt(3)/2) * edge
    }
    
    func renderEquilateralTriangle(in rect: CGRect, in context: CGContext) -> CGRect {
        let height = height(forEquilateralTriangleEdge: rect.width)
        
        let containerRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: height)
        
        context.setStrokeColor(UIColor.black.cgColor)
        
        let path = UIBezierPath()
        
//        rect.minY + (tP2.y - tP1.y) / 2
        
        path.move(to: .init(x: rect.midX, y: rect.minY))
        path.addLine(to: .init(x: rect.minX, y: rect.minY + height))
        path.addLine(to: .init(x: rect.maxX, y: rect.minY + height))
        path.close()
        
        context.addPath(path.cgPath)
        context.strokePath()
        
        return containerRect
    }
    
    func generateSquareRect(within triangleRect: CGRect) -> CGRect {
        let tP1 = CGPoint(x: triangleRect.midX, y: triangleRect.minY)
        let tP2 = CGPoint(x: triangleRect.minX, y: triangleRect.maxY)
        let tP3 = CGPoint(x: triangleRect.maxX, y: triangleRect.maxY)
        
        // Realization middle point of edge can not make a square inside it. It will go out of traingle.
        // Find that edge, we can use pythagores.
        // The triangle formed above will also have 60deg angle as edge will be parallel. so all edge equal.
        // after getting side of square or upper triangle we can get points of rect.
        
        let innerHalfEdge = 0.464 * triangleRect.width
        
        let offset = (triangleRect.width - innerHalfEdge) / 2
        let x1 = tP2.x + offset
        let y1 = tP2.y - innerHalfEdge
        
        let finalRect = CGRect(x: x1, y: y1, width: innerHalfEdge, height: innerHalfEdge)
        
        return finalRect
    }
    
    func renderSquare(in rect: CGRect, in context: CGContext) -> CGRect {
        let squareRect = generateSquareRect(within: rect)
        
        context.setStrokeColor(UIColor.black.cgColor)
        let path = UIBezierPath(rect: squareRect)
        
        context.addPath(path.cgPath)
        context.strokePath()
        
        return squareRect
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vi = RecursiveShapeView(count: 10)
        view.addSubview(vi)
        vi.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vi.topAnchor.constraint(equalTo: view.topAnchor),
            vi.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vi.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vi.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}






// MARK: --
// previous attempt
extension RecursiveShapeView {
    
    func drawEquilateralTriangle(rect: CGRect, context: CGContext, recursed: Bool = false) -> CGRect {
        context.setStrokeColor(UIColor.black.cgColor)
        
        let sideLength = rect.width
        let height = (sqrt(3)/2) * sideLength
                
        let point1 = CGPoint(x: rect.midX, y: rect.minY)
        let point2 = CGPoint(x: rect.minX, y: recursed ? rect.maxY : height)
        let point3 = CGPoint(x: rect.maxX, y: recursed ? rect.maxY : height)
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: point1)
        trianglePath.addLine(to: point2)
        trianglePath.addLine(to: point3)
        trianglePath.close()
        
        // Set the line width for the triangle
        context.setLineWidth(1.0)
        
        // Add the triangle path to the context and stroke it
        context.addPath(trianglePath.cgPath)
        context.strokePath()
        
        let newRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: recursed ? rect.maxY : height)
        return newRect
    }
    
    func drawSquare(rect: CGRect, context: CGContext, recursed: Bool = false) -> CGRect {
        context.setStrokeColor(UIColor.red.cgColor)

        let minX = rect.midX/2
        let maxX = 2 * minX
        let minY = rect.midY
        let maxY = rect.maxY
        let squareRect = CGRect(
            x: minX,
            y: recursed ? rect.minY : minY,
            width: maxX,
            height: maxY - minY)
        
        let squarePath: UIBezierPath
        if recursed {
            squarePath = UIBezierPath()
            let xDiff = (rect.midX - rect.minX)/2
            let yDiff = (rect.midY - rect.minY)/2
            let x = rect.minX + xDiff
            let y = rect.minY + yDiff
            squarePath.move(to: CGPoint(x: x, y: y))
            squarePath.addLine(to: .init(x: x, y: y + yDiff))
            squarePath.addLine(to: .init(x: x+(2*xDiff), y: y+yDiff))
            squarePath.addLine(to: .init(x: x+(2*xDiff), y: y))

            squarePath.close()
            
            context.addPath(squarePath.cgPath)
            context.strokePath()
            
            return CGRect(x: x, y: y, width: (2*xDiff), height: yDiff)
            
        } else {
            squarePath = UIBezierPath(rect: squareRect)
            
            context.addPath(squarePath.cgPath)
            context.strokePath()
        }

        

        return squareRect
    }
}
