//
//  PPRCardBattleVC.swift
//  PokerRoyaleRivals
//
//  Created by SunTory on 2024/9/27.
//

import UIKit
import SceneKit

class PPRCardBattleVC: UIViewController {
    
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var swapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        scnView.scene = scene
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        scene.rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let cardBattleScene = CardBattleScene(scene: scene)
        cardBattleScene.dealCards()
        
        swapButton.addTarget(self, action: #selector(swapCards), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func swapCards() {
        if let scene = scnView.scene {
            let cardBattleScene = CardBattleScene(scene: scene)
            cardBattleScene.removeAndDealNewCards()
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: [:])
        
        if let hit = hitResults.first {
            let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(45.degreesToRadians), z: 0, duration: 0.5)
            hit.node.runAction(rotateAction)
        }
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat {
        return CGFloat(Int(self)) * .pi / 180
    }
}

import SceneKit

class CardBattleScene {
    
    var playerOneCardNode: SCNNode!
    var playerTwoCardNode: SCNNode!
    let cardImages: [String] = ["A♠️", "2♠️", "3♠️", "4♠️", "5♠️", "6♠️", "7♠️", "8♠️", "9♠️", "10♠️", "J♠️", "Q♠️", "K♠️",
                                "A♥️", "2♥️", "3♥️", "4♥️", "5♥️", "6♥️", "7♥️", "8♥️", "9♥️", "10♥️", "J♥️", "Q♥️", "K♥️",
                                "A♦️", "2♦️", "3♦️", "4♦️", "5♦️", "6♦️", "7♦️", "8♦️", "9♦️", "10♦️", "J♦️", "Q♦️", "K♦️",
                                "A♣️", "2♣️", "3♣️", "4♣️", "5♣️", "6♣️", "7♣️", "8♣️", "9♣️", "10♣️", "J♣️", "Q♣️", "K♣️"]
    
    var scene: SCNScene
    var tableNode: SCNNode!
    
    init(scene: SCNScene) {
        self.scene = scene
        setupTable()
    }
    
    func setupTable() {
        tableNode = SCNNode()
        tableNode.position = SCNVector3(x: 0, y: 5, z: 0)
        
        let tableMaterial = SCNMaterial()
        tableMaterial.diffuse.contents = UIColor(named: "appColor_AE009F")
        tableMaterial.isDoubleSided = true
        
        let tableBox = SCNBox(width: 12, height: 6, length: 1, chamferRadius: 1)
        tableBox.materials = [tableMaterial]
        
        let tableGeometryNode = SCNNode(geometry: tableBox)
        tableNode.addChildNode(tableGeometryNode)
        
        addLabel(text: "Player One", position: SCNVector3(x: -3, y: 1.8, z: 2))
        addLabel(text: "Player Two", position: SCNVector3(x: 1, y: 1.8, z: 2))
        
        scene.rootNode.addChildNode(tableNode)
    }
    
    func addLabel(text: String, position: SCNVector3) {
        let labelNode = SCNNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
        textGeometry.font = UIFont.boldSystemFont(ofSize: 4)
        textGeometry.firstMaterial?.diffuse.contents = UIColor(named: "appColor_white")
        
        labelNode.geometry = textGeometry
        labelNode.position = position
        labelNode.scale = SCNVector3(0.1, 0.1, 0.1)
        
        tableNode.addChildNode(labelNode)
    }
    
    func dealCards() {
        playerOneCardNode = createCardNode(position: SCNVector3(-2, 0, 2))
        playerTwoCardNode = createCardNode(position: SCNVector3(2, 0, 2))
        
        tableNode.addChildNode(playerOneCardNode)
        tableNode.addChildNode(playerTwoCardNode)
        
        assignRandomCardTextures()
    }
    
    func createCardNode(position: SCNVector3) -> SCNNode {
        let cardPlane = SCNPlane(width: 2, height: 3)
        let cardNode = SCNNode(geometry: cardPlane)
        
        let cardMaterial = SCNMaterial()
        cardMaterial.diffuse.contents = UIImage(named: "card_back")
        cardPlane.materials = [cardMaterial]
        
        cardNode.position = position
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        cardNode.constraints = [billboardConstraint]
        
        return cardNode
    }
    
    func assignRandomCardTextures() {
        let playerOneCard = cardImages.randomElement() ?? "A♠️"
        let playerTwoCard = cardImages.randomElement() ?? "A♥️"
        
        playerOneCardNode.name = playerOneCard
        playerTwoCardNode.name = playerTwoCard
        
        updateCardTexture(cardNode: playerOneCardNode, card: playerOneCard)
        updateCardTexture(cardNode: playerTwoCardNode, card: playerTwoCard)
    }
    
    func updateCardTexture(cardNode: SCNNode, card: String) {
        if let plane = cardNode.geometry as? SCNPlane {
            let cardMaterial = SCNMaterial()
            cardMaterial.diffuse.contents = UIImage(named: card)
            plane.materials = [cardMaterial]
            
            cardNode.name = card
        }
    }
    
    func removeAndDealNewCards() {
        playerOneCardNode?.removeFromParentNode()
        playerTwoCardNode?.removeFromParentNode()
        
        dealCards()
        declareWinner()
    }
    
    func declareWinner() {
        let winner: String
        
        if let playerOneCardName = playerOneCardNode.name,
           let playerTwoCardName = playerTwoCardNode.name,
           let playerOneIndex = cardImages.firstIndex(of: playerOneCardName),
           let playerTwoIndex = cardImages.firstIndex(of: playerTwoCardName) {
            
            if playerOneIndex > playerTwoIndex {
                winner = "Player One Wins!"
            } else if playerOneIndex < playerTwoIndex {
                winner = "Player Two Wins!"
            } else {
                winner = "It's a Tie!"
            }
            
        } else {
            winner = "Error: Could not determine the winner."
        }
        
        showAlert(title: "Game Over", message: winner)
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
