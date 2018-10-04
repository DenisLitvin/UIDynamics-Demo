//
//  ViewController.swift
//  UIDynamics Demo
//
//  Created by Denis Litvin on 10/4/18.
//  Copyright © 2018 Denis Litvin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    var animator: UIDynamicAnimator!
    var behavior1: UIDynamicBehavior!
    var behavior2: UIDynamicBehavior!
    var item: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: self.view)
        
        
        item = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.addSubview(item)
        item.backgroundColor = .red
        
        let item2 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 80))
        item2.backgroundColor = .blue
        item2.frame = CGRect(x: (self.view.frame.width + 10) / 2,
                             y: self.view.frame.height - item2.frame.height * 2,
                             width: item2.frame.width,
                             height: item2.frame.height)
        view.addSubview(item2)
        
        behavior1 = {
            let behavior = UIDynamicBehavior()
            behavior.addChildBehavior(UISnapBehavior(item: item, snapTo: view.center))
            return behavior
        }()
        
        behavior2 = {
            let behavior = UIDynamicBehavior()
            let gravity = UIGravityBehavior(items: [item])
            gravity.magnitude = 2
            behavior.addChildBehavior(gravity)
            
            let collision = UICollisionBehavior(items: [item, item2])
            collision.translatesReferenceBoundsIntoBoundary = true
            behavior.addChildBehavior(collision)
            
            let dib1 = UIDynamicItemBehavior(items: [item, self.view])
            dib1.allowsRotation = true
            dib1.elasticity = 0.6
            dib1.density = 50
            behavior.addChildBehavior(dib1)
            
            let dib2 = UIDynamicItemBehavior(items: [item2])
            dib2.allowsRotation = true
            dib2.elasticity = 1
            dib2.friction = 0
            dib2.density = 7
            dib2.addAngularVelocity(10, for: item2)
            behavior.addChildBehavior(dib2)
            
            let anchor = UIAttachmentBehavior(item: item2, attachedToAnchor: item2.center)
            behavior.addChildBehavior(anchor)
            return behavior
        }()
        
        item.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan)))
        item.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        
        applyBehavior()
    }
    var lastOrigin = CGPoint.zero
    @objc func pan(_ gr: UIPanGestureRecognizer) {
        if gr.state == .began {
            lastOrigin = item.layer.position
            animator.removeAllBehaviors()
        }
        else if gr.state == .changed {
            let translation = gr.translation(in: self.view)
            let newOrigin = CGPoint(x: translation.x + lastOrigin.x, y: translation.y + lastOrigin.y)
            self.item.layer.position = newOrigin
        }
        else if gr.state == .ended {
            applyBehavior(velocity: gr.velocity(in: self.view))
        }
    }
    var flag = true
    @objc func tap() {
        flag.toggle()
        applyBehavior()
    }
    private func applyBehavior(velocity: CGPoint = .zero) {
        animator.removeAllBehaviors()
        animator.addBehavior(flag ? behavior1 : behavior2)
        let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: velocity.x, dy: velocity.y)
        pushBehavior.magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y) * 0.4
        animator.addBehavior(pushBehavior)
        
    }
}
