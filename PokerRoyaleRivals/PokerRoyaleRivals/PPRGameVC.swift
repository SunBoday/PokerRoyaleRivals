//
//  PPRGameVC.swift
//  PokerRoyaleRivals
//
//  Created by SunTory on 2024/9/27.
//

import UIKit
import SceneKit

class PPRGameViewVC: UIViewController {

    @IBOutlet weak var sceneView: SCNView!

    var cardNodes: [SCNNode] = []
    var score = 0
    var gameScene: SCNScene!
    var scoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        startCardFall()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.backgroundColor = .clear
        setupScoreLabel()
        sceneView.scene?.physicsWorld.contactDelegate = self
    }

    func setupScene() {
        gameScene = SCNScene()
        sceneView.scene = gameScene
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 10
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 10)
        gameScene.rootNode.addChildNode(cameraNode)
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 10, 10)
        gameScene.rootNode.addChildNode(lightNode)
    }

    func setupScoreLabel() {
        scoreLabel = UILabel(frame: CGRect(x: self.view.frame.width - 150, y: 60, width: 100, height: 40))
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .right
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.textColor = .white
        self.view.addSubview(scoreLabel)
    }

    func startCardFall() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.spawnCard()
        }
    }

    func spawnCard() {
        let cardGeometry = SCNPlane(width: 2.0, height: 3.0)
        cardGeometry.firstMaterial?.diffuse.contents = UIImage(named: "cardImage")
        let cardNode = SCNNode(geometry: cardGeometry)
        cardNode.position = SCNVector3(Float.random(in: -3...3), 5, 0)
        cardNode.name = "card"
        cardNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        cardNode.physicsBody?.isAffectedByGravity = false
        cardNode.physicsBody?.velocity = SCNVector3(0, -1, 0)
        cardNode.physicsBody?.categoryBitMask = 2
        cardNode.physicsBody?.contactTestBitMask = 1
        cardNode.physicsBody?.collisionBitMask = 1
        gameScene.rootNode.addChildNode(cardNode)
        cardNodes.append(cardNode)
    }

    @objc func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        let tapLocation = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(tapLocation, options: nil)
        if hitResults.isEmpty {
            releaseDart(from: tapLocation)
        }
    }

    func releaseDart(from position: CGPoint) {
        let projectedPoint = sceneView.unprojectPoint(SCNVector3(position.x, position.y, 0))
        let dartStartPos = SCNVector3(projectedPoint.x, projectedPoint.y, 0)
        let dartGeometry = SCNCylinder(radius: 0.2, height: 2.0)
        dartGeometry.firstMaterial?.diffuse.contents = UIImage(named: "dartImage")
        let dartNode = SCNNode(geometry: dartGeometry)
        dartNode.position = dartStartPos
        dartNode.name = "dart"
        dartNode.eulerAngles.z = .pi
        dartNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        dartNode.physicsBody?.isAffectedByGravity = false
        dartNode.physicsBody?.categoryBitMask = 1
        dartNode.physicsBody?.contactTestBitMask = 2
        dartNode.physicsBody?.collisionBitMask = 2
        let dartDirection = SCNVector3(0, 5, 0)
        dartNode.physicsBody?.velocity = dartDirection
        gameScene.rootNode.addChildNode(dartNode)
    }
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension PPRGameViewVC: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if (nodeA.name == "dart" && nodeB.name == "card") || (nodeA.name == "card" && nodeB.name == "dart") {
            score += 1
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score: \(self.score)"
            }
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
        }
    }
}

