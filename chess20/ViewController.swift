// TO DO: 
// 1. Ocisti kod od sugavog i glupih komentara i segmentiraj ga uz pomoc ekstenzija
// 2. Testiraj kako se ponasa rezultat kad uvedes kalkulaciju za tri-cetiri-pet poteza, pre toga ocisti tablu od suvisnih figura
// 3. implementiraj resenje za CHECK MATE jer ga sada nemas



//
//  ViewController.swift
//  chess20
//
//  Created by Dimic Milos on 4/13/17.
//  Copyright © 2017 G11. All rights reserved.
//

import UIKit
import AVFoundation
var dummie: ViewController?

class ViewController: UIViewController {
    
    let referencePiecesNames = ["kraljica", "top", "lovac", "skakac"]
    var player: AVAudioPlayer?
    
    var specialRuleImplemented: Bool = false // vodi racuna o tome da li je neko specijalno pravilo odigrano u tekucem potezu
    var specialMoveKind: SpecialMoveKind?
    
    var enPassant: [Int:Int] = [:] // u ovaj dictionary se upisuje koji je tag pesaka i koja je vrednost polja na koje taj pesak moze da stupi i da odigra en passant
    var clearEnpassant = true // ovaj bool cuva enPassant dictionary od brisanja samo u narednom potezu jer je potreban radi iscitavanja kada protivnik vuce potez
    var whenToClearEnPassant: Int? // vodi racuna o tome da tek kad su dva uspesna poteza napravljena daje mogucnost da se clearEnPassant promeni u true
    var chessPiecesTagsWhoMadeMove = Set<Int>() // set u koji se insertuju tagovi figura koje su napravili potez, a sve radi ogranicavanja pesaka na samo jedan field napred i proveravanja jednog od uslova za rokadu
    
    var noFieldIluminated = true // daje podatak o tome kako ce se prvi ili drugi korisnicki field selection ponasati. Grana ga u odredjenom pravcu
    
    var appLoadedForTheFirstTime = true // grana tok ka punjenju klasa
    var numberOfRows = 10
    var numberOfColumns = 10
    var fields = [OneField]()
    var moves = [Move]()
    ///*
    var fieldsDirectory: Dictionary = ["a1" : "topBeli", "b1" : "skakacBeli", "c1" : "lovacBeli", "d1" : "kraljicaBeli",
                                       "e1" : "kraljBeli", "f1" : "lovacBeli", "g1" : "skakacBeli", "h1" : "topBeli",
                                       "a2" : "pesakBeli", "b2" : "pesakBeli", "c2" : "pesakBeli", "d2" : "pesakBeli",
                                       "e2" : "pesakBeli", "f2" : "pesakBeli", "g2" : "pesakBeli", "h2" : "pesakBeli",
                                       "a8" : "topCrni", "b8" : "skakacCrni", "c8" : "lovacCrni", "d8" : "kraljicaCrni",
                                       "e8" : "kraljCrni", "f8" : "lovacCrni", "g8" : "skakacCrni", "h8" : "topCrni",
                                       "a7" : "pesakCrni", "b7" : "pesakCrni", "c7" : "pesakCrni", "d7" : "pesakCrni",
                                       "e7" : "pesakCrni", "f7" : "pesakCrni", "g7" : "pesakCrni", "h7" : "pesakCrni"]
    
    var chessPiecesTagDirectory: Dictionary = ["a1" : 1010, "b1" : 1020, "c1" : 1030, "d1" : 1050, "e1" : 1040, "f1" : 1060, "g1" : 1070, "h1" : 1080,
                                               "a2" : 2010, "b2" : 2020, "c2" : 2030, "d2" : 2040, "e2" : 2050, "f2" : 2060, "g2" : 2070, "h2" : 2080,
                                               "a8" : -1010, "b8" : -1020, "c8" : -1030, "d8" : -1050, "e8" : -1040, "f8" : -1060, "g8" : -1070, "h8" : -1080,
                                               "a7" : -2010, "b7" : -2020, "c7" : -2030, "d7" : -2040, "e7" : -2050, "f7" : -2060, "g7" : -2070, "h7" : -2080]    //*/
       /*
    var fieldsDirectory: Dictionary = ["a8" : "topBeli",
                                       "c7" : "skakacBeli",
                                       "c8" : "skakacCrni",
                                       "e5" : "kraljBeli",
                                       "f8" : "lovacCrni",
                                       "e8" : "kraljCrni"]
    
    var chessPiecesTagDirectory: Dictionary = ["a8" : 1010, "c7" : 1020, "c8" : -1020, "e8" : -1040, "f8" : -1060, "e5" : 1040]
 
     */
    
    let validniUnosi: Set = ["a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8",
                             "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8",
                             "e1", "e2", "e3", "e4", "e5", "e6", "e7", "e8", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8",
                             "g1", "g2", "g3", "g4", "g5", "g6", "g7", "g8", "h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dummie = self
        
        if appLoadedForTheFirstTime {
            PopulateChessTableForTheFirstTime()
        }
    }
    
    func playSound() {
       //print(" play sound")
        let url = Bundle.main.url(forResource: "wrong", withExtension: ".mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func PopulateChessTableForTheFirstTime() {
        //print(" pop chess table for the first time")
        // ova funckija se poziva samo jednom, i to pri startu aplikacije
        // poziva grupu funkcija koje u zbiru generisu pocetni prikaz
        CreateChessTable()
        LoadClassesWithDEFAULTStartPositionOfAllChessPieces()
        LoadClassesWithDEFAULTStartingChessPiecesTagsAndColorTags()
        //print("79")
        UpdateScreenForNewArrangment()
        appLoadedForTheFirstTime = false
    }
    
    func UpdateScreenForNewArrangment(callingFunctionName: String = #function) {
         //print("Calling Function UpdateScreenForNewArrangment: \(callingFunctionName)")

        // brise sa ekrana sve UIImageView koji reprezentuju neku pojedenu sah figuricu
        // brise sa ekrana sve UIButtone koji reprezentuju polja sah table
        // iscrtava novu tablu i figurice na osnovu updejtovanih podataka
        for clan in view.subviews {
            if clan is UIImageView && (clan.tag >= -2096 && clan.tag <= 2096) {
                clan.removeFromSuperview()
            }
            if clan is UIButton && (clan.tag >= 10000 && clan.tag <= 10909) {
                clan.removeFromSuperview()
            }
        }
        DrawChessBoard()
        DrawChessPieces()
        DrawCasulities()
    }
    
    enum ColorOfTheChessPiece {
        case White
        case Black
    }
    
    enum Direction {
        case vertical
        case horizontal
        case diagonal
        case unknown
    }
    
    enum SpecialMoveKind {
        case enPassant
        case promotion
        case castling
    }
    
    struct Move {
        // struktura u koju se ubacuje svaki uspesno nacinjen potez
        var originFieldValue: Int?
        var destinationFieldValue: Int?
        var whichColorMoved: ColorOfTheChessPiece?
        var casulties: Bool
        var originHeldPiece: String?
        var originPieceTag: Int?
        var destinationHeldPiece: String?
        var destinationPieceTag: Int?
        var specialMoveImplemented: Bool
        var specialMoveKind: SpecialMoveKind?
    }
    
    class OneField {
        // sadrzi podatke o imenu polja (A1), vrednosti polja na osnovu pozicije polja (10101), poziciji polja X i Y (67 x 277),
        // da li je polje zauzeto (true), koja figura je na polju (topBeli) i koji je tag te figurice koja se nalazi na tom polju
        var fieldName: String?; var fieldPositionValue: Int?; var fieldPositionX: CGFloat?; var fieldPositionY: CGFloat?;
        var fieldSize: CGFloat?; var fieldColor: UIColor?; var userInteractionEnabled: Bool?; var fieldIsPopulated = false;
        var fieldCarriesPieceNamed: String?; var fieldCarriesPieceWithTag: Int?; var fieldCarriesPieceColor: ColorOfTheChessPiece?; var fieldTitle: String?
        var fieldIsIluminated: Bool?; var fieldIluminationColor: UIColor?
        
        init(fieldName: String, fieldPositonValue: Int, fieldPositionX: CGFloat, fieldPositionY: CGFloat, fieldSize: CGFloat, fieldColor: UIColor, userInteractionEnabled: Bool, fieldIsIluminated: Bool) {
            self.fieldName = fieldName
            self.fieldPositionValue = fieldPositonValue
            self.fieldPositionX = fieldPositionX
            self.fieldPositionY = fieldPositionY
            self.fieldSize = fieldSize
            self.fieldColor = fieldColor
            self.userInteractionEnabled = userInteractionEnabled
            self.fieldIsIluminated = fieldIsIluminated
        }
        
        init(fieldName: String, fieldPositonValue: Int, fieldPositionX: CGFloat, fieldPositionY: CGFloat, fieldSize: CGFloat, fieldColor: UIColor, fieldTitle: String, userInteractionEnabled: Bool, fieldIsIluminated: Bool) {
            self.fieldName = fieldName
            self.fieldPositionValue = fieldPositonValue
            self.fieldPositionX = fieldPositionX
            self.fieldPositionY = fieldPositionY
            self.fieldSize = fieldSize
            self.fieldColor = fieldColor
            self.fieldTitle = fieldTitle
            self.userInteractionEnabled = userInteractionEnabled
            self.fieldIsIluminated = fieldIsIluminated
        }
        
        init(fieldName: String, fieldPositionValue: Int, fieldIsPopulated: Bool, fieldCarriesPieceNamed: String?, fieldCarriesPieceWithTag: Int?, fieldCarriesPieceColor: ColorOfTheChessPiece?) {
            self.fieldName = fieldName
            self.fieldPositionValue = fieldPositionValue
            self.fieldIsPopulated = fieldIsPopulated
            self.fieldCarriesPieceNamed = fieldCarriesPieceNamed
            self.fieldCarriesPieceWithTag = fieldCarriesPieceWithTag
            self.fieldCarriesPieceColor = fieldCarriesPieceColor
        }
    }

    func CreateChessTable() {
       //print("create chess table")
        // na osnovu velicine ekrana odredjuje velicinu jednog polja. Tabla se stampa u formatu 10x10 plus dodatak za izbrisane figure (ili levo, ili ispod table)
        // svakom polju se dodeljuje boja
        // nekim poljima se dodeljuje naziv
        // svako polje dobija svoj tag koji je u zavisnosti od naziva polja (a1 nosi tag 10101, c3 nosi tag 10303, h8 10808...)
        let buttonWidthHeight: CGFloat?; var gap: CGFloat?

        if view.frame.maxX < view.frame.maxY {
            gap = (view.frame.maxX - view.frame.minX) / 10
        } else {
            gap = (view.frame.maxY - view.frame.minY) / 10
        }
        //gap = 20 // ovu liniju skolniti u potpunosto ukoliko zelis da se sam pozicionira sa jos dva polja stofa sa strane
        if view.frame.maxX < view.frame.maxY {
            buttonWidthHeight = (view.frame.maxX - view.frame.minX - 2 * gap!) / 10
        } else {
            buttonWidthHeight = (view.frame.maxY - view.frame.minY - 2 * gap!) / 10
        }
        
        var i = 9
        for row in 0...numberOfRows - 1 {
            for column in 0...numberOfColumns - 1 {
                var buttonColor: UIColor; var fieldColor: UIColor; let userPickedFieldColorOne: UIColor = .red
                let userPickedFieldColorTwo: UIColor = .cyan; let userPickedFrameColor: UIColor = .gray
                
                let button = UIButton(frame: CGRect(x: gap! + (CGFloat(column) * buttonWidthHeight!),
                                                    y: gap! + (CGFloat(row) * buttonWidthHeight!),
                                                    width: buttonWidthHeight!,
                                                    height: buttonWidthHeight!))
                
                if ((column == 1 || column == 3 || column == 5 || column == 7) && (row == 2 || row == 4 || row == 6 || row == 8)) ||
                   ((column == 2 || column == 4 || column == 6 || column == 8) && (row == 1 || row == 3 || row == 5 || row == 7)) {
                    fieldColor = userPickedFieldColorOne
                } else {
                    fieldColor = userPickedFieldColorTwo
                }
                
                button.isUserInteractionEnabled = true
                
                let letter = UnicodeScalar(65 + column - 1)?.escaped(asASCII: false)
                if (row == 0 || row == 9) && !((column == 0) || ((column == 9)))  {
                    button.setTitle(letter!, for: .normal)
                    fieldColor = userPickedFrameColor
                    button.isUserInteractionEnabled = false
                }
                
                if (column == 0 || column == 9) && !((row == 0) || ((row == 9))) {
                    button.setTitle(String(row + i), for: .normal)
                    fieldColor = userPickedFrameColor
                    button.isUserInteractionEnabled = false
                }
                buttonColor = fieldColor
                button.backgroundColor = buttonColor
                button.tag = column * 100 + row + i + 10000
                button.addTarget(self, action: #selector(UserPressedField), for: .touchUpInside)
                
                if button.title(for: .normal) != nil {
                    fields.append(OneField(fieldName: (letter! + String(row + i)).lowercased(),
                                           fieldPositonValue: button.tag,
                                           fieldPositionX: button.frame.origin.x,
                                           fieldPositionY: button.frame.origin.y,
                                           fieldSize: button.frame.height,
                                           fieldColor: fieldColor,
                                           fieldTitle: button.title(for: .normal)!,
                                           userInteractionEnabled: button.isUserInteractionEnabled,
                                           fieldIsIluminated: false))
                } else {
                    fields.append(OneField(fieldName: (letter! + String(row + i)).lowercased(),
                                           fieldPositonValue: button.tag,
                                           fieldPositionX: button.frame.origin.x,
                                           fieldPositionY: button.frame.origin.y,
                                           fieldSize: button.frame.height,
                                           fieldColor: fieldColor,
                                           userInteractionEnabled: button.isUserInteractionEnabled,
                                           fieldIsIluminated: false))
                }
            }
            i -= 2
        }
    }
    
    func DrawChessBoard() {
        //print(" draw chess board")
        // iscrtava buttone koji predstavljaju sah tablu i dodeljuje im boju, tag, da li su reaktivna, titl i target
        for member in fields {
            let button = UIButton(frame: CGRect(x: member.fieldPositionX!, y: member.fieldPositionY!, width: member.fieldSize!, height: member.fieldSize!))
            if member.fieldIsIluminated! {
                button.backgroundColor = member.fieldIluminationColor
            } else {
                button.backgroundColor = member.fieldColor
            }
            button.tag = member.fieldPositionValue!
            button.isUserInteractionEnabled = member.userInteractionEnabled!
            button.setTitle(member.fieldTitle, for: .normal)
            button.addTarget(self, action: #selector(UserPressedField), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    
    func DrawCasulities() {
       //print(" draw casulties")
        // crta popjedene figurice na pozicijama u zavisnosti od devicxe orientation 
        
        var numberOfCasulties: Int = 0
        var numberOfCasultiyRows: CGFloat = 0
        
        for move in moves {
            if move.casulties {
                numberOfCasulties += 1
                if numberOfCasulties == 9 {
                    numberOfCasulties = 1
                    numberOfCasultiyRows += 1
                }
                
                var casultiyX: CGFloat?
                var casultiyY: CGFloat?
               
                if UIDeviceOrientationIsPortrait(UIDevice.current.orientation){
                    casultiyX = (fields[numberOfCasulties].fieldPositionX)!
                    casultiyY = ((fields.first?.fieldPositionY)! * 10) + ((fields.first?.fieldSize)! * numberOfCasultiyRows)
                } else if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                    casultiyX = ((fields.first?.fieldPositionY)! * 10) + ((fields.first?.fieldSize)! * numberOfCasultiyRows)
                    casultiyY = (fields[numberOfCasulties].fieldPositionX)!
                } else {
                    casultiyX = (fields[numberOfCasulties].fieldPositionX)!
                    casultiyY = ((fields.first?.fieldPositionY)! * 10) + ((fields.first?.fieldSize)! * numberOfCasultiyRows)
                }

                let casultyPiece = UIImageView.init(frame: CGRect(x: casultiyX!, y: casultiyY!, width: (fields.first?.fieldSize)!, height: (fields.first?.fieldSize)!))
                casultyPiece.image = UIImage(named: move.destinationHeldPiece!) // izbacuje nil ako je postojala mogucnost za enpassant a nije iskoriscena pa sam stavio u liniji 487 gde se apenduje move u slucaju enpassanta da je casultie false
                casultyPiece.tag = move.destinationPieceTag!
                view.addSubview(casultyPiece)
            }
        }
    }
    
    func DrawChessPieces() {
        //print(" draw chess pieces")
        // iscrtava figurice na osnovu citanja trenutno vazeg niza klasa sa svim pripadajucim informacijama
        for member in fields {
            if member.fieldIsPopulated {
                let chessPiece = UIImageView(frame: CGRect(x: member.fieldPositionX!,
                                                           y: member.fieldPositionY!,
                                                           width: member.fieldSize!,
                                                           height: member.fieldSize!))
                chessPiece.image = UIImage(named: member.fieldCarriesPieceNamed!)
                chessPiece.tag = member.fieldCarriesPieceWithTag!
                view.addSubview(chessPiece)
            }
        }
    }
    
    func LoadClassesWithDEFAULTStartPositionOfAllChessPieces() {
        //print(" load classes w deful start positiona")
        // na osnovu fieldDirectory umece u klase informacije o tome na kojim poljima se nalazi koja figurica
        // updejtuje informaciju o tome da li je polje zauzete ili nije
        for key in fieldsDirectory.keys {
            for field in fields{
                if key == field.fieldName! {
                    field.fieldCarriesPieceNamed = fieldsDirectory[key]
                    field.fieldIsPopulated = true
                }
            }
        }
    }
    
    func LoadClassesWithDEFAULTStartingChessPiecesTagsAndColorTags() {
      //print("load classes with default start chess tags ")
        // na osnovu chessPiecesTagDirectory umece u klase informacije o tagu figurice koja se nalazi na odgovarajucem polju
        // dodeljuje svakom polju koje nosi neku figuricu informaciju o tome da li je tu bela ili crna figurica
        for key in chessPiecesTagDirectory.keys {
            for field in fields {
                if key == field.fieldName! {
                    field.fieldCarriesPieceWithTag = chessPiecesTagDirectory[key]
                    if field.fieldCarriesPieceWithTag! > 0 {
                        field.fieldCarriesPieceColor = ColorOfTheChessPiece.White
                    } else {
                        field.fieldCarriesPieceColor = ColorOfTheChessPiece.Black
                    }
                }
            }
        }
    }
    
    func AnimatedChessPieceMove(callingFunctionName: String = #function, chessPieceTag: Int, xDestination: CGFloat, yDestination: CGFloat) {
        //print("Calling Function AnimatedChessPieceMove: \(callingFunctionName)")
        //print("animate cpm ")
        // animira pokrete figurica
        //print("animated")
        for piece in view.subviews {
            if piece.tag == chessPieceTag {
                UIView.animate(withDuration: 0.6, animations: {
                    piece.frame.origin = CGPoint(x: xDestination, y: yDestination)
                }, completion: {
                    finished in self.UpdateScreenForNewArrangment()
                })
            }
        }
    }
    
    func UserPressedField(button: UIButton) {
        //print(" user press field \(button.tag)")
        // kaze sta se radi ako je user pritisne neko dugme na sah tabli
        if noFieldIluminated && FieldIsOccupied(fieldValue: button.tag) && isItMyTurn(fieldValue: button.tag) { // hendluje situaciju u kojoj ni jedno polje nije jos iluminated

            for member in fields {
                if member.fieldPositionValue == button.tag {
                    member.fieldIsIluminated = true
                    member.fieldIluminationColor = UIColor.yellow
                    ShowPotentialFields(originClass: member)
                    //print("375")
                    UpdateScreenForNewArrangment()
                }
            }
            noFieldIluminated = false    // ne zaboraviti da se restaruje ova vrednost nakon konacnog izvrsavanja poteza
        } else if !noFieldIluminated { // hendluje situaciju u kojoj je jedno polje iluminated a korisnik onda klikne na polje na kom se nalazi opet njegova figura te ga od tog trenutka definisemo ne kao destination vec kao novi origin
            for originField in fields {
                if originField.fieldIsIluminated! {
                    for destinationField in fields {
                        if destinationField.fieldPositionValue == button.tag {
                            if destinationField.fieldCarriesPieceColor == originField.fieldCarriesPieceColor {
                                for field in fields {
                                    if field.fieldIsIluminated! {
                                        field.fieldIsIluminated = false
                                    }
                                }
                                destinationField.fieldIsIluminated = true
                                destinationField.fieldIluminationColor = UIColor.yellow
                                //ShowPotentialFields(originClass: destinationField)
                                //print("394")
                                
                               UpdateScreenForNewArrangment()
                                
                                //break
                            } else { // hendluje deo kad je korisnik vec odabrao origin i sada bira neki destination koji nije njegova figura vec svako drugo polje na tabli
                                if MoveIsValid(originClass: originField, destinationClass: destinationField, callerIsHuman: true, simulationCalling: false) && !KingIsSteppingIntoCheck(inputClass: originField, outputClass: destinationField) {
                                    //print("move je validan, ovim potezom kralj koji se nalazi na mestu: \(!KingInCheck(inputClass: originField, outputClass: destinationField)) ne ulazi u opasnu poziciju")
                                    // iluminiraj polje zutom bojom u trajanju od 1 sekund
                                    // animirano pomeri figuricu na novu poziciju tako sto upises nove podatke u klase
                                    // upisi potez u moves
                                    // proveri da li ima casulties, ako ima smesti izvrsi njihovo brisanje iz klasa i umetanje u strukturu moves
                                    // oslobodi sve klase iluminiranih polja, znaci sve na false
                                    destinationField.fieldIsIluminated = true
                                    destinationField.fieldIluminationColor = UIColor.yellow
                                    //print("407")
                                    UpdateScreenForNewArrangment()
                                    // bez animacije ukoliko je promotion da bi se promotion option validno pojavio na ekranu
                                    if specialMoveKind != SpecialMoveKind.promotion {
                                        AnimatedChessPieceMove(chessPieceTag: originField.fieldCarriesPieceWithTag!,
                                                               xDestination: destinationField.fieldPositionX!,
                                                               yDestination: destinationField.fieldPositionY!)

                                    }
                                    //print("insertujem u chessPiecesWhoMadeMove")
                                    chessPiecesTagsWhoMadeMove.insert(originField.fieldCarriesPieceWithTag!)
                                    //print("appendujem u moves 422")
                                    moves.append(Move(originFieldValue: originField.fieldPositionValue,
                                                      destinationFieldValue: destinationField.fieldPositionValue,
                                                      whichColorMoved: originField.fieldCarriesPieceColor,
                                                      casulties: destinationField.fieldIsPopulated,
                                                      originHeldPiece: originField.fieldCarriesPieceNamed,
                                                      originPieceTag: originField.fieldCarriesPieceWithTag,
                                                      destinationHeldPiece: destinationField.fieldCarriesPieceNamed,
                                                      destinationPieceTag: destinationField.fieldCarriesPieceWithTag,
                                                      specialMoveImplemented: specialRuleImplemented,
                                                      specialMoveKind: specialMoveKind))
                                    
                                    if moves.count == whenToClearEnPassant {
                                        clearEnpassant = true
                                    }
                                    
                                    destinationField.fieldIsPopulated = true // ovde obratiti paznju sta da se radi za special cases tipa en passant
                                    destinationField.fieldCarriesPieceColor = originField.fieldCarriesPieceColor
                                    destinationField.fieldCarriesPieceWithTag = originField.fieldCarriesPieceWithTag
                                    destinationField.fieldCarriesPieceNamed = originField.fieldCarriesPieceNamed
                                    
                                    originField.fieldIsPopulated = false
                                    originField.fieldCarriesPieceColor = nil
                                    originField.fieldCarriesPieceWithTag = nil
                                    originField.fieldCarriesPieceNamed = nil
                                    
                                    originField.fieldIsIluminated = false
                                    destinationField.fieldIsIluminated = false
                                    noFieldIluminated = true
                                    
                                    specialRuleImplemented = false
                                    specialMoveKind = nil
                                    
                                    // bavi se slucajevima u kojima je neko specijaln pravilo izvedeno i to na bazi pregleda poslednjeg unosa u moves gde stoji da li je neko specijalno pravilo implementirano i navodi se koje je to pravilo
                                    if (moves.last?.specialMoveImplemented)! {
                                        // enPassant
                                        if moves.last?.specialMoveKind == SpecialMoveKind.enPassant {
                                            let x: Int?
                                            if destinationField.fieldCarriesPieceColor == ColorOfTheChessPiece.White {
                                                x = -1
                                            } else {
                                                x = 1
                                            }
                                            
                                            for enPassantField in fields {
                                                if destinationField.fieldPositionValue! + x! == enPassantField.fieldPositionValue! {
                                                    //print("appendujem u moves 468")
                                                    moves.append(Move(originFieldValue: nil,
                                                                      destinationFieldValue: enPassantField.fieldPositionValue,
                                                                      whichColorMoved: nil,
                                                                      casulties: true, ////// en passant test proba ispravka
                                                                      originHeldPiece: nil,
                                                                      originPieceTag: nil,
                                                                      destinationHeldPiece: enPassantField.fieldCarriesPieceNamed,
                                                                      destinationPieceTag: enPassantField.fieldCarriesPieceWithTag,
                                                                      specialMoveImplemented: true,
                                                                      specialMoveKind: nil))
                                                    
                                                    enPassantField.fieldIsPopulated = false
                                                    enPassantField.fieldCarriesPieceColor = nil
                                                    enPassantField.fieldCarriesPieceWithTag = nil
                                                    enPassantField.fieldCarriesPieceNamed = nil
                                                }
                                            }
                                            //print("480")
                                            UpdateScreenForNewArrangment()
                                        }
                                        // promotion
                                        if moves.last?.specialMoveKind == SpecialMoveKind.promotion {
                                            OfferPromotion(destinationClass: destinationField)
                                        }
                                        // rokada
                                        if moves.last?.specialMoveKind == SpecialMoveKind.castling {
                                            ExecuteCastling()
                                        }
                                        
                                    }
                                    // nakon kompletno izvrsenog poteza (i nakon izvrsenja eventuanih special rules) proveravamo da li je protivnicki kralj stavljen u CHeckPoz
                                    if KingInCheck().inCheck {
                                        var kingField = KingInCheck().kingField!
                                        var opponentField = KingInCheck().opponentField!
                                        
                                        
                                        
                                        func WaitForShitToClear(seconds: Double){
                                            // kupuje vreme dok se ne izvrse sve eventualne animacije, te zapravo ceka cistu poziciju da bi pokrenuo pravi Wait
                                            //print("WAIT FOR SHIT TO CLEAR")
                                            // ceka da se zavrse animacije i ostala sranja
                                            view.isUserInteractionEnabled = false
                                            Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds),
                                                                 repeats: false,
                                                                 block: { (timer) in Wait(seconds: 1)})
                                        }
                                        
                                        func Wait(seconds: Double){
                                            // obelezava purple polja na kojima je king koje je pod checkom i figura koja mu preti
                                            //print("I HOPE SHIT ENDED")
                                            kingField.fieldIsIluminated = true
                                            opponentField.fieldIsIluminated = true
                                            kingField.fieldIluminationColor = UIColor.purple
                                            opponentField.fieldIluminationColor = UIColor.purple
                                            //print("522")
                                            UpdateScreenForNewArrangment()
                                            //print("sad treba da pocene pauz dovolja za prikaz purple")
                            
                                            
                                            Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds),
                                                                 repeats: false,
                                                                 block: { (timer) in CleenUpPotentialFields()})
                                        }

                                        func CleenUpPotentialFields() {
                                            //print("sad treba da se zavrsi pauza")
                                            //print("CleenUpPotentialFields")
                                            // func gasi iluminaciju na na kingField i na polju koje ga ugrozava i updejtuje prikaz i aktivira user interact
                                            kingField.fieldIsIluminated = false
                                            opponentField.fieldIsIluminated = false
                                            view.isUserInteractionEnabled = true
                                            
                                            //print("519")
                                            UpdateScreenForNewArrangment()
                                            
                                            
                                        }
                                        
                                        WaitForShitToClear(seconds: 0.75)
                                        
                                    }
                                    if swAI.isOn {
                                        CheckIfItIsComputerTurn()
                                    }
                                    
                                } else {
                                    // iluminiraj polje crvenom bojom u trajanju od 1 sekund
                                    // play some stupid sound
                                    playSound()
                                }
                            }
                        }
                    }
                }
            }


                        // proveri da li je za odredisno polje potez validan ili ne
            // 1. ako jeste validan - nastavi sa povlacenjem poteza, upisom novih informacija o figurama koje se pomeraju ili jedu ili spec pravila i osvezi ekran
            // 2. ako nije validan, pusti neki glupi zvuk
            // 3. ovo nije lose mesto da korisniku bljesne belo gde sve moze da postavi figuri i ako ima kill da bljesne to polje malo drugacije
            
        }
    }
    
    func isItMyTurn(fieldValue: Int) -> Bool {
        //print("is it my turn ")
        // treba napisati celu funckiju koja vodi racuna o tome ko je na redu gde se navode sledeci slucajevi:
        // 1. ukoliko nije bilo ranijih poteza funckija vraca true bez obzira ko povlaci potez
        // 2. ukoliko je bilo ranijih poteza utvrditi da onaj koji vuce potez nije onaj koji je potez vec povukao
        // 3. onaj koji je na redu je na tom redu sve dok se potez ne izvrsi
        // 4. nakon sto je potez izvrsen obavezno uneti novu vrednost u varijablu koja belezi ko je nacinio prethodni potez
        
        if moves.count == 0 {
            return true
        } else {
            for field in fields {
                if field.fieldPositionValue == fieldValue {
                    if field.fieldCarriesPieceColor != moves.last?.whichColorMoved {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return false
    }
    
    func FieldIsOccupied(fieldValue: Int) -> Bool {
//print("field is occupied ")
        // vraca true ako je field populated i false ako nije
        for field in fields {
            if field.fieldPositionValue == fieldValue {
                if field.fieldIsPopulated {
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }
    
    func MoveIsValid(callingFunctionName: String = #function, originClass: OneField, destinationClass: OneField, callerIsHuman: Bool, simulationCalling: Bool) -> Bool {
        //print("move is valid called by \(callingFunctionName) ")
        //print("PAWN \(callerIsHuman)")
        
        if abs(originClass.fieldCarriesPieceWithTag!) >= 2010 && abs(originClass.fieldCarriesPieceWithTag!) <= 2090 {
            return Pawn(originClass: originClass, destinationClass: destinationClass, callerIsHuman: callerIsHuman) && TheWayIsClear(originFieldValue: originClass.fieldPositionValue! - 10000, destinationFieldValue: destinationClass.fieldPositionValue! - 10000, simulationCalling: simulationCalling)
        }
        
        if abs(originClass.fieldCarriesPieceWithTag!) >= 1020 && abs(originClass.fieldCarriesPieceWithTag!) <= 1029 ||
           abs(originClass.fieldCarriesPieceWithTag!) >= 1070 && abs(originClass.fieldCarriesPieceWithTag!) <= 1079 {
            return Knight(originClass: originClass, destinationClass: destinationClass)
        }
        
        if abs(originClass.fieldCarriesPieceWithTag!) == 1040 {
            return King(originClass: originClass, destinationClass: destinationClass, callerIsHuman: callerIsHuman) && TheWayIsClear(originFieldValue: originClass.fieldPositionValue! - 10000, destinationFieldValue: destinationClass.fieldPositionValue! - 10000, simulationCalling: simulationCalling)
        }
        
        if abs(originClass.fieldCarriesPieceWithTag!) >= 1030 && abs(originClass.fieldCarriesPieceWithTag!) <= 1039 ||
           abs(originClass.fieldCarriesPieceWithTag!) >= 1060 && abs(originClass.fieldCarriesPieceWithTag!) <= 1069 {
            return Bishop(originClass: originClass, destinationClass: destinationClass) && TheWayIsClear(originFieldValue: originClass.fieldPositionValue! - 10000, destinationFieldValue: destinationClass.fieldPositionValue! - 10000, simulationCalling: simulationCalling)
        }
       
        if abs(originClass.fieldCarriesPieceWithTag!) >= 1050 && abs(originClass.fieldCarriesPieceWithTag!) <= 1059 {
            return Queen(originClass: originClass, destinationClass: destinationClass) && TheWayIsClear(originFieldValue: originClass.fieldPositionValue! - 10000, destinationFieldValue: destinationClass.fieldPositionValue! - 10000, simulationCalling: simulationCalling)
        }
        
        if abs(originClass.fieldCarriesPieceWithTag!) >= 1010 && abs(originClass.fieldCarriesPieceWithTag!) <= 1019 ||
           abs(originClass.fieldCarriesPieceWithTag!) >= 1080 && abs(originClass.fieldCarriesPieceWithTag!) <= 1089 {
            //print("usao sam u proveru za rook u func move is valid")
            return Rook(originClass: originClass, destinationClass: destinationClass) &&
                   TheWayIsClear(originFieldValue: originClass.fieldPositionValue! - 10000, destinationFieldValue: destinationClass.fieldPositionValue! - 10000, simulationCalling: simulationCalling)
        }
        print("vracam false iz moveisvalid bez ulaska u figurice tagove i sl")
        return false
    }
    
    func TheWayIsClear(callingFunctionName: String = #function, originFieldValue: Int, destinationFieldValue: Int, simulationCalling: Bool) -> Bool {
      //print(" the way is clear called by \(callingFunctionName)")
        // proverava za svako polje da li je populated
        var checkThisArray = [OneField]()
        
        
        if simulationCalling {
            checkThisArray = chessFields
        } else {
            checkThisArray = fields
        }

        for field in checkThisArray {
            for fieldToCheck in FieldsToCheck(direction: NatureOfTheMovement(originFieldValue: originFieldValue,
                                                                             destinationFieldValue: destinationFieldValue),
                                              originFieldValue: originFieldValue,
                                              destinationFieldValue: destinationFieldValue){
                                                if field.fieldPositionValue == fieldToCheck {
                                                    if field.fieldIsPopulated {
                                                        if (originFieldValue == 101 && destinationFieldValue == 104) || (originFieldValue == 10101 && destinationFieldValue == 10104) {
                                                            //print("vracam false iz the way is clear \(originFieldValue, destinationFieldValue) jer je polje \(field.fieldName) zauzeto u ovom trenutku iscitavanja sa \(field.fieldCarriesPieceNamed)")
                                                        }
                                                        
                                                        return false
                                                    }
                                                }
            }
        }
        
        if (originFieldValue == 101 && destinationFieldValue == 104)  || (originFieldValue == 10101 && destinationFieldValue == 10104) {
            //print("vracam true iz the way is clear \(originFieldValue, destinationFieldValue) jer gledam u sledece podatke:")
            for field in checkThisArray {
                print(field.fieldName, field.fieldIsPopulated, field.fieldCarriesPieceNamed)
            }
        }
        
        

        return true
    }
    
    func FieldsToCheck(direction: Direction, originFieldValue: Int, destinationFieldValue: Int) -> Array<Int> {
        //print(" fields to check")
        // daje niz field values izmedju origin i destination polja
        var hundreds: Bool?
        var unit: Bool?
        var arrayOfFieldsToCheck = [Int]()
        
        if originFieldValue / 100 * 100 > destinationFieldValue / 100 * 100 {
            hundreds = false
        } else if originFieldValue / 100 * 100 < destinationFieldValue / 100 * 100 {
            hundreds = true
        }
        
        if originFieldValue / 100 * 100 - originFieldValue > destinationFieldValue / 100 * 100 - destinationFieldValue {
            unit = true
        } else if originFieldValue / 100 * 100 - originFieldValue < destinationFieldValue / 100 * 100 - destinationFieldValue {
            unit = false
        }
        
        
        if direction == Direction.vertical {
            if abs((originFieldValue / 100 * 100 - originFieldValue) - (destinationFieldValue / 100 * 100 - destinationFieldValue)) < 2 {
                return []
            } else {
                if unit! {
                    for i in 1..<abs((originFieldValue / 100 * 100 - originFieldValue) - (destinationFieldValue / 100 * 100 - destinationFieldValue)) {
                        arrayOfFieldsToCheck.append(originFieldValue + 1 * i + 10000)
                    }
                } else {
                    for i in 1..<abs((originFieldValue / 100 * 100 - originFieldValue) - (destinationFieldValue / 100 * 100 - destinationFieldValue)) {
                        arrayOfFieldsToCheck.append(originFieldValue - 1 * i + 10000)
                    }
                }
            }
        }
            
        
        if direction == Direction.horizontal {
            if abs(originFieldValue - destinationFieldValue) / 100 < 2 {
              return []
            } else {
                if hundreds! {
                    for i in 1..<abs(originFieldValue - destinationFieldValue) / 100 {
                        arrayOfFieldsToCheck.append(originFieldValue + 100 * i + 10000)
                    }
                } else {
                    for i in 1..<abs(originFieldValue - destinationFieldValue) / 100 {
                        arrayOfFieldsToCheck.append(originFieldValue - 100 * i + 10000)
                    }
                }
            }
        }

        if direction == Direction.diagonal {
            if abs(originFieldValue - destinationFieldValue)  <= 101 {
                return []
            } else {
                if hundreds! {
                    if unit! {
                        for i in 1..<abs(originFieldValue - destinationFieldValue) / 100 {
                            arrayOfFieldsToCheck.append(originFieldValue + 101 * i + 10000)
                        }
                    } else {
                        for i in 1...abs(originFieldValue - destinationFieldValue) / 100 {
                            arrayOfFieldsToCheck.append(originFieldValue + 99 * i + 10000)
                        }
                    }
                    
                } else {
                    if unit! {
                        for i in 1...abs(originFieldValue - destinationFieldValue) / 100 { // 1..<(198)/100 -> 1...1 znaci samo i = 1
                            arrayOfFieldsToCheck.append(originFieldValue - 99 * i + 10000)
                        }
                    } else {
                        for i in 1..<abs(originFieldValue - destinationFieldValue) / 100 {  // 1..<(202)/100 -> 1..<2 znaci samo i = 1
                            arrayOfFieldsToCheck.append(originFieldValue - 101 * i + 10000)
                        }
                    }
                }
            }
        }
        return arrayOfFieldsToCheck
    }

    func NatureOfTheMovement(callingFunctionName: String = #function, originFieldValue: Int, destinationFieldValue: Int) -> Direction {
        //print(" nature of the movement \(originFieldValue, destinationFieldValue) called by \(callingFunctionName)")
        // daje kakvo je kretanje: vertikalno, horizontalno, dijagonalno ili unknown
        if originFieldValue / 100 == destinationFieldValue / 100 {
            if originFieldValue / 100 * 100 - originFieldValue != destinationFieldValue / 100 * 100 - destinationFieldValue {
                //print("vertical")
                return Direction.vertical
            }
        }
        
        if originFieldValue / 100 != destinationFieldValue / 100 {
            if originFieldValue / 100 * 100 - originFieldValue == destinationFieldValue / 100 * 100 - destinationFieldValue {
                //print("horizontal")
                return Direction.horizontal
            }
        }
        
        if originFieldValue / 100 != destinationFieldValue / 100 {
            if originFieldValue / 100 * 100 - originFieldValue != destinationFieldValue / 100 * 100 - destinationFieldValue {
                if abs(originFieldValue / 100 - destinationFieldValue / 100) == abs((originFieldValue / 100 * 100 - originFieldValue) - (destinationFieldValue / 100 * 100 - destinationFieldValue)) {
                    //print("diagonal")
                    return Direction.diagonal
                }
            }
        }
        //print("unknown 792")
        return Direction.unknown
    }
    
    func Bishop(originClass: OneField, destinationClass: OneField) -> Bool {
        //print(" bishop")
        if NatureOfTheMovement(originFieldValue: originClass.fieldPositionValue!, destinationFieldValue: destinationClass.fieldPositionValue!) == Direction.diagonal {
            return true
        } else {
            return false
        }
    }
    
    func Rook(callingFunctionName: String = #function, originClass: OneField, destinationClass: OneField) -> Bool {
        //print(" rook called by \(callingFunctionName)")
        if NatureOfTheMovement(originFieldValue: originClass.fieldPositionValue!, destinationFieldValue: destinationClass.fieldPositionValue!) == Direction.vertical ||
            NatureOfTheMovement(originFieldValue: originClass.fieldPositionValue!, destinationFieldValue: destinationClass.fieldPositionValue!) == Direction.horizontal {
            return true
        } else {
            return false
        }
    }

    
    func Queen(originClass: OneField, destinationClass: OneField) -> Bool {
        //print("queen ")
        if NatureOfTheMovement(originFieldValue: originClass.fieldPositionValue!, destinationFieldValue: destinationClass.fieldPositionValue!) == Direction.diagonal ||
           NatureOfTheMovement(originFieldValue: originClass.fieldPositionValue!, destinationFieldValue: destinationClass.fieldPositionValue!) == Direction.horizontal ||
           NatureOfTheMovement(originFieldValue: originClass.fieldPositionValue!, destinationFieldValue: destinationClass.fieldPositionValue!) == Direction.vertical {
            return true
        } else {
            return false
        }
    }
    
    func Knight(originClass: OneField, destinationClass: OneField) -> Bool {
      //print("knight ")
        if originClass.fieldPositionValue! - 98 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! - 199 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! - 201 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! - 102 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 102 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 201 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 199 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 98 == destinationClass.fieldPositionValue! {
            return true
        } else {
            return false
        }
    }
    
    func King(originClass: OneField, destinationClass: OneField, callerIsHuman: Bool) -> Bool {
        if callerIsHuman {
            //print(" king")
            //print(" ovo je prin iz kinga za chessPiecesTagsWhoMadeMove \(chessPiecesTagsWhoMadeMove)")
            // proverava uslov za rokadu sa leve strane i za crne i za bele
            if destinationClass.fieldPositionValue! == originClass.fieldPositionValue! - 200 {
                //print("usao sam u funckiju kralj, onaj deo za rokadu sto proverava polja desno od kralja")
                if originClass.fieldCarriesPieceWithTag! > 0 {
                    if !chessPiecesTagsWhoMadeMove.contains(originClass.fieldCarriesPieceWithTag!) && !chessPiecesTagsWhoMadeMove.contains(1010) {
                        // ispunjen je uslov za rokadu jer nisu pomerni, proveri jos da li padaju pod check
                        if CastlingPossible(originClass: originClass, fieldsToCheck: [10301, 10401, 10501]) {
                            specialRuleImplemented = true
                            specialMoveKind = SpecialMoveKind.castling
                            return true
                        }
                    }
                } else {
                    if !chessPiecesTagsWhoMadeMove.contains(originClass.fieldCarriesPieceWithTag!) && !chessPiecesTagsWhoMadeMove.contains(-1010) {
                        // ispunjen je uslov za rokadu jer nisu pomerni, proveri jos da li padaju pod check
                        
                        if CastlingPossible(originClass: originClass, fieldsToCheck: [10308, 10408, 10508]) {
                            specialRuleImplemented = true
                            specialMoveKind = SpecialMoveKind.castling
                            return true
                        }
                    }
                }
                // proverava uslov za rokadu sa desne strane i za crne i za bele
            } else if destinationClass.fieldPositionValue! == originClass.fieldPositionValue! + 200 {
                //print("usao sam u funckiju kralj, onaj deo za rokadu sto proverava polja levo od kralja")
                if originClass.fieldCarriesPieceWithTag! > 0 {
                    //print("usao sam u 769 \(!chessPiecesTagsWhoMadeMove.contains(originClass.fieldCarriesPieceWithTag!), !chessPiecesTagsWhoMadeMove.contains(1080))")
                    if !chessPiecesTagsWhoMadeMove.contains(originClass.fieldCarriesPieceWithTag!) && !chessPiecesTagsWhoMadeMove.contains(1080) {
                        // ispunjen je uslov za rokadu jer nisu pomerni, proveri jos da li padaju pod check
                        if CastlingPossible(originClass: originClass, fieldsToCheck: [10501, 10601, 10701]) {
                            specialRuleImplemented = true
                            specialMoveKind = SpecialMoveKind.castling
                            return true
                        }
                    }
                } else {
                    //print("usao sam u 773 \(!chessPiecesTagsWhoMadeMove.contains(originClass.fieldCarriesPieceWithTag!), !chessPiecesTagsWhoMadeMove.contains(-1080))")
                    if !chessPiecesTagsWhoMadeMove.contains(originClass.fieldCarriesPieceWithTag!) && !chessPiecesTagsWhoMadeMove.contains(-1080) {
                        // ispunjen je uslov za rokadu jer nisu pomerni, proveri jos da li padaju pod check
                        if CastlingPossible(originClass: originClass, fieldsToCheck: [10508, 10608, 10708]) {
                            specialRuleImplemented = true
                            specialMoveKind = SpecialMoveKind.castling
                            return true
                        }
                    }
                }
            }
        }
        
        if originClass.fieldPositionValue! - 99 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! - 100 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! - 101 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 1 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! - 1 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 99 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 100 == destinationClass.fieldPositionValue! ||
            originClass.fieldPositionValue! + 101 == destinationClass.fieldPositionValue! {
            return true
        } else {
            return false
        }
    }
    
    func Pawn(originClass: OneField, destinationClass: OneField, callerIsHuman: Bool) -> Bool {
        //print(" pawn")
        var pawnPossibleFields = Set<Int>()

        // limitira kretanje pesaka na jedno ili dva polja unapred u zavisnosti od toga da li je to prvi potez pesaka
        // ne dozvoljava pesaku da ide napred ukoliko je polje ispred njega zauzeto bilo kojom figurom
        if chessPiecesTagsWhoMadeMove.contains(originClass.fieldCarriesPieceWithTag!) { // pokriva deo koji se odnosi na pesake koji su vec napravili prvi potez
            if originClass.fieldCarriesPieceWithTag! < 0 { // crni
                if originClass.fieldPositionValue! - 1 == destinationClass.fieldPositionValue! {
                    if !destinationClass.fieldIsPopulated {
                        pawnPossibleFields.insert(originClass.fieldPositionValue! - 1)
                        //print("insertujem \(originClass.fieldPositionValue! - 1) iz 818")
                    }
                }
            } else { // beli
                if originClass.fieldPositionValue! + 1 == destinationClass.fieldPositionValue! {
                    if !destinationClass.fieldIsPopulated {
                        pawnPossibleFields.insert(originClass.fieldPositionValue! + 1)
                        //print("insertujem \(originClass.fieldPositionValue! + 1) iz 825")
                    }
                }
            }
        } else { // pokriva deo koji se odnosi na pesake koji nisu napravili do sada ni jedan potez
            
                if originClass.fieldCarriesPieceWithTag! < 0 { // crni
                    if originClass.fieldPositionValue! - 1 == destinationClass.fieldPositionValue! {
                        if !destinationClass.fieldIsPopulated {
                            pawnPossibleFields.insert(originClass.fieldPositionValue! - 1)
                            //print("insertujem \(originClass.fieldPositionValue! - 1) iz 834")
                        }
                    }
                    if originClass.fieldPositionValue! - 2 == destinationClass.fieldPositionValue! {
                        
                        if originClass.fieldName == "a7" && destinationClass.fieldName == "a5" ||
                            originClass.fieldName == "b7" && destinationClass.fieldName == "b5" ||
                            originClass.fieldName == "c7" && destinationClass.fieldName == "c5" ||
                            originClass.fieldName == "d7" && destinationClass.fieldName == "d5" ||
                            originClass.fieldName == "e7" && destinationClass.fieldName == "e5" ||
                            originClass.fieldName == "f7" && destinationClass.fieldName == "f5" ||
                            originClass.fieldName == "g7" && destinationClass.fieldName == "g5" ||
                            originClass.fieldName == "h7" && destinationClass.fieldName == "h5" {
                                
                                
                                if !destinationClass.fieldIsPopulated {
                                    pawnPossibleFields.insert(originClass.fieldPositionValue! - 2)
                                    //print("insertujem \(originClass.fieldPositionValue! - 2) iz 840")
                                    
                                }
                                
                        }
                        
                    }
                } else { // beli
                    if originClass.fieldPositionValue! + 1 == destinationClass.fieldPositionValue! {
                        if !destinationClass.fieldIsPopulated {
                            pawnPossibleFields.insert(originClass.fieldPositionValue! + 1)
                            //print("insertujem \(originClass.fieldPositionValue!) + 1 iz 848")
                        }
                    }
                    
                    if originClass.fieldName == "a2" && destinationClass.fieldName == "a4" ||
                        originClass.fieldName == "b2" && destinationClass.fieldName == "b4" ||
                        originClass.fieldName == "c2" && destinationClass.fieldName == "c4" ||
                        originClass.fieldName == "d2" && destinationClass.fieldName == "d4" ||
                        originClass.fieldName == "e2" && destinationClass.fieldName == "e4" ||
                        originClass.fieldName == "f2" && destinationClass.fieldName == "f4" ||
                        originClass.fieldName == "g2" && destinationClass.fieldName == "g4" ||
                        originClass.fieldName == "h2" && destinationClass.fieldName == "h4" {
                        
                        if originClass.fieldPositionValue! + 2 == destinationClass.fieldPositionValue! {
                            if !destinationClass.fieldIsPopulated {
                                pawnPossibleFields.insert(originClass.fieldPositionValue! + 2)
                                //print("insertujem \(originClass.fieldPositionValue! + 2) iz 854")
                            }
                        }
                        
                    }
                    
            }
            
        }
        // omogucava da pesak ide jedno polje unapred-ukoso ukoliko se na tom polju nalazi neka figura (o tome koje je boje se ne vodi racuna jer ne postoji mogucnos takve greske)
        if originClass.fieldCarriesPieceWithTag! < 0 {
            if originClass.fieldPositionValue! - 101 == destinationClass.fieldPositionValue! || originClass.fieldPositionValue! + 99 == destinationClass.fieldPositionValue! {
                if destinationClass.fieldIsPopulated {
                    pawnPossibleFields.insert(destinationClass.fieldPositionValue!)
                    //print("insertujem \(destinationClass.fieldPositionValue!) iz 864")
                }
            }
        } else {
            if originClass.fieldPositionValue! + 101 == destinationClass.fieldPositionValue! || originClass.fieldPositionValue! - 99 == destinationClass.fieldPositionValue! {
                if destinationClass.fieldIsPopulated {
                    pawnPossibleFields.insert(destinationClass.fieldPositionValue!)
                    //print("insertujem \(destinationClass.fieldPositionValue!) iz 871")
                }
            }
        }
        // bavi se iskljucivo otvaranjem mogucnosti za sledujuci potez protivnika u kome se protivniku otvara mogucnos da sa pesakom koji nosi tacno odredjen tag moze da stupi na tacno odredjeno polje koje se nalazi odmah iza nativ pesaka koji ovde tu mogucnost i stvara. Vrsi se upis u dictionary sa vezom [tagFigurice:polje] i ovaj dictionary, to jest njegov values (ukoliko protivnik klikne na svog pesaka koji ima mogucnost da izvrsi enpassant i uputi ga tacno na zadatu odredisno polje koje podpada po enpassant) biva kopiran u possible fields. Ovo kopiranje se vrsi samo dok protivnik ne povuce jedan uspesan potez, a nakon toga se dictionary prazni do sledeceg punjenja ukoliko se takva mogucnost stvori
        if callerIsHuman && pawnPossibleFields.contains(destinationClass.fieldPositionValue!) {
            if originClass.fieldPositionValue! + 2 == destinationClass.fieldPositionValue! || originClass.fieldPositionValue! - 2 == destinationClass.fieldPositionValue! {
                for field in fields {
                    if field.fieldPositionValue == destinationClass.fieldPositionValue! + 100  || field.fieldPositionValue == destinationClass.fieldPositionValue! - 100 {
                        if field.fieldIsPopulated {
                            if abs(field.fieldCarriesPieceWithTag!) >= 2010 || abs(field.fieldCarriesPieceWithTag!) <= 2090 {
                                if field.fieldCarriesPieceColor != destinationClass.fieldCarriesPieceColor {
                                    if originClass.fieldCarriesPieceWithTag! > 0 {
                                        enPassant[field.fieldCarriesPieceWithTag!] = destinationClass.fieldPositionValue! - 1
                                    } else {
                                        enPassant[field.fieldCarriesPieceWithTag!] = destinationClass.fieldPositionValue! + 1
                                    }
                                    clearEnpassant = false
                                    whenToClearEnPassant = moves.count + 2
                                }
                            }
                        }
                    }
                }
            }
        }
        // u possible fields ubacuje polje/a ukoliko je kliknuta tacno odredjena figura i upucena na tacno odredjenu poziciju (ovo vrsi duplu radnju da bi PossibleFields uvek pokazivale sva moguca polja, pa i ona koja podpadaju pod special rules. Svakako ce func iskociti sa true prilikom iteracije dictionarija )
        if enPassant[originClass.fieldCarriesPieceWithTag!] == destinationClass.fieldPositionValue! {
            pawnPossibleFields.insert(destinationClass.fieldPositionValue!)
            //print("insertujem \(destinationClass.fieldPositionValue!) iz 900")
        }
        // prazni enpassant ukoliko je true
        if clearEnpassant {
            enPassant = [:]
        }
        // vrsi proveru celog dictionarija za sve keys (koji ovde reprezentuju tagove figurica) i ukoliko korisnik pokusava da nacini potez sa figuicom koja nosi taj tag on vrsi dalju proveru da li korisnik pokusava da uputi tu figuricu na tacno onu poziciju koja je ista kao i value tog taga u dictionariju. Ako je to slucaj, on signalizira da je specijalno pravilo implementirano i koje je to pravilo
        for pieceTag in enPassant.keys {
            if callerIsHuman && pieceTag == originClass.fieldCarriesPieceWithTag {
                if enPassant[originClass.fieldCarriesPieceWithTag!] == destinationClass.fieldPositionValue! {
                    specialRuleImplemented = true
                    specialMoveKind = SpecialMoveKind.enPassant
                    //print("vracam true iz enpassant")
                    return true
                }
            }
        }
        // proverava da li je bilo koji pesak stigao na bilo koji kraj table kako bi aktvirao PROMOTION ukoliko je pozivalac funkcije human
        if callerIsHuman && pawnPossibleFields.contains(destinationClass.fieldPositionValue!) {
            for letter in 1...8 {
                if destinationClass.fieldName == (UnicodeScalar(97 + letter - 1)?.escaped(asASCII: false))! + String(1) ||
                    destinationClass.fieldName == (UnicodeScalar(97 + letter - 1)?.escaped(asASCII: false))! + String(8) {
                    //print("promotion moguc")
                    specialRuleImplemented = true
                    specialMoveKind = SpecialMoveKind.promotion
                    //print("vracam true iz promotion")
                    return true
                }
            }
        }
        // vrsi onu najcescu proveru a to je da li je neki najobicniji potez pesaka validan, tako sto proverava da li je zadato odrediste u pawnPossibleFields
        //print("pawn possible fields \(pawnPossibleFields, callerIsHuman)")
        for pawnPossibleField in pawnPossibleFields {
            //print("pawn possible field \(pawnPossibleField) iz linije 933")
            if destinationClass.fieldPositionValue == pawnPossibleField {
                //print("vracam true iz iteracije pawnpossiblefields 935")
                return true
            }
        }
        return false
    }
    
    func OfferPromotion(destinationClass: OneField) {
        //print("offer promotion")
        // OBAVEZNO DISABLE DEVICE ROTATION ILI POZOVI FUNC I UVEDI VARIJABLU KOJA PRATI DA LI JE FUNC ON
        // OBAVEZNO DISABLE USER INTERACTION NA SVIM OSTLIM POLJIMA OSIM OVA CETIRI BUTTONA
        // formira cetiri buttona koji nude promotion figurice
        let x: String
        let backgoundColor: UIColor
        if destinationClass.fieldCarriesPieceColor == ColorOfTheChessPiece.White {
            x = "Beli"
            backgoundColor = UIColor.black
        } else {
            x = "Crni"
            backgoundColor = UIColor.white
        }
        
        for field in fields {
            let referenceFields = [10306, 10506, 10304, 10504]
            
            for i in 0..<referenceFields.count {
                if referenceFields[i] == field.fieldPositionValue {
                    let promotionButton = UIButton(frame: CGRect(x: field.fieldPositionX!, y: field.fieldPositionY!,
                                                                 width: field.fieldSize! * 2, height: field.fieldSize! * 2))
                    promotionButton.backgroundColor = backgoundColor
                    promotionButton.setImage(UIImage(named: referencePiecesNames[i] + x), for: .normal)
                    promotionButton.tag = 100000 * (i+1)
                    promotionButton.isUserInteractionEnabled = true
                    promotionButton.addTarget(self, action: #selector(ExecutePromotion), for: .touchUpInside)
                    view.addSubview(promotionButton)
                }
            }
        }
    }


    
    func ExecutePromotion(sender: UIButton) {
        //print("execute promotion")
        let x: String
        let y: Int
        var pieceHighestTagValue = 0
        
        if moves.last?.whichColorMoved == ColorOfTheChessPiece.White {
            x = "Beli"
            y = 1
        } else {
            x = "Crni"
            y = -1
        }
        
        for field in fields {
            if field.fieldCarriesPieceNamed == referencePiecesNames[sender.tag / 100000 - 1] + x {
                if abs(field.fieldCarriesPieceWithTag!) > pieceHighestTagValue {
                    pieceHighestTagValue = field.fieldCarriesPieceWithTag!
                }
            }
        }
        
        for destinationField in fields {
            if destinationField.fieldPositionValue == moves.last?.destinationFieldValue {
                destinationField.fieldCarriesPieceColor = moves.last?.whichColorMoved
                destinationField.fieldIsPopulated = true
                destinationField.fieldCarriesPieceNamed = referencePiecesNames[sender.tag / 100000 - 1] + x
                destinationField.fieldCarriesPieceWithTag = pieceHighestTagValue + y
                //print("appendujem u moves 1067")
                moves.append(Move(originFieldValue: moves.last?.destinationFieldValue,
                                  destinationFieldValue: destinationField.fieldPositionValue,
                                  whichColorMoved: destinationField.fieldCarriesPieceColor,
                                  casulties: false,
                                  originHeldPiece: moves.last?.destinationHeldPiece,
                                  originPieceTag: moves.last?.originPieceTag,
                                  destinationHeldPiece: destinationField.fieldCarriesPieceNamed,
                                  destinationPieceTag: destinationField.fieldCarriesPieceWithTag,
                                  specialMoveImplemented: true,
                                  specialMoveKind: SpecialMoveKind.promotion))
            }
        }
        //print("1071")
        UpdateScreenForNewArrangment()
    }
    
    func CastlingPossible(originClass: OneField, fieldsToCheck: Array<Int>) -> Bool {
          //print("usao sam u funckiju CastlingPossible koja samo proverava da li su sledeca polja pod opasnuscu \(fieldsToCheck)")
        for fieldToCheckForCheck in fieldsToCheck {
            for fieldToCheckClass in fields {
                if fieldToCheckClass.fieldPositionValue == fieldToCheckForCheck {
                    for field in fields {
                        if field.fieldCarriesPieceColor != originClass.fieldCarriesPieceColor {
                            if field.fieldIsPopulated {
                                if MoveIsValid(originClass: field, destinationClass: fieldToCheckClass, callerIsHuman: false, simulationCalling: false) {
                                    //print("move nije valid je sa polja \(field.fieldPositionValue) preti opasnost na polje \(fieldToCheckClass.fieldPositionValue)")
                                    return false
                                }
                            }
                        }
                    }
                }
            }
        }
        return true
    }
    
    func ExecuteCastling() {
        var originFieldClass: OneField?
        var destinationFieldClass: OneField?
        
        if moves.last?.destinationFieldValue == 10708 {
            for field in fields {
                if field.fieldPositionValue == 10808 {
                    originFieldClass = field
                } else if field.fieldPositionValue == 10608 {
                    destinationFieldClass = field
                }
            }
        } else if moves.last?.destinationFieldValue == 10701 {
            for field in fields {
                if field.fieldPositionValue == 10801 {
                    originFieldClass = field
                } else if field.fieldPositionValue == 10601 {
                    destinationFieldClass = field
                }
            }
        } else if moves.last?.destinationFieldValue == 10308 {
            for field in fields {
                if field.fieldPositionValue == 10108 {
                    originFieldClass = field
                } else if field.fieldPositionValue == 10408 {
                    destinationFieldClass = field
                }
            }
        } else if moves.last?.destinationFieldValue == 10301 {
            for field in fields {
                if field.fieldPositionValue == 10101 {
                    originFieldClass = field
                } else if field.fieldPositionValue == 10401 {
                    destinationFieldClass = field
                }
            }
        }
        //print("appendujem u moves 1142")
        moves.append(Move(originFieldValue: originFieldClass?.fieldPositionValue,
                          destinationFieldValue: destinationFieldClass?.fieldPositionValue,
                          whichColorMoved: originFieldClass?.fieldCarriesPieceColor,
                          casulties: false,
                          originHeldPiece: originFieldClass?.fieldCarriesPieceNamed,
                          originPieceTag: originFieldClass?.fieldCarriesPieceWithTag,
                          destinationHeldPiece: nil,
                          destinationPieceTag: nil,
                          specialMoveImplemented: true,
                          specialMoveKind: SpecialMoveKind.castling))
        
        //print("animate: \(originFieldClass?.fieldCarriesPieceWithTag, destinationFieldClass?.fieldPositionX, destinationFieldClass?.fieldPositionY)")
        AnimatedChessPieceMove(chessPieceTag: (originFieldClass?.fieldCarriesPieceWithTag)!, xDestination: (destinationFieldClass?.fieldPositionX)!, yDestination: (destinationFieldClass?.fieldPositionY)!)
        
        for destinationField in fields {
            if destinationField.fieldPositionValue == destinationFieldClass?.fieldPositionValue {
                for originField in fields {
                    if originField.fieldPositionValue == originFieldClass?.fieldPositionValue {
                        destinationField.fieldIsPopulated = true
                        destinationField.fieldCarriesPieceColor = originField.fieldCarriesPieceColor
                        destinationField.fieldCarriesPieceNamed = originField.fieldCarriesPieceNamed
                        destinationField.fieldCarriesPieceWithTag = originField.fieldCarriesPieceWithTag
                        
                        originField.fieldIsPopulated = false
                        originField.fieldCarriesPieceColor = nil
                        originField.fieldCarriesPieceNamed = nil
                        originField.fieldCarriesPieceWithTag = nil
                    }
                }
            }
        }
    }
    
    func KingIsSteppingIntoCheck(inputClass: OneField, outputClass: OneField) -> Bool {
        // func proverava da li kralj svojim stupanjem na neko polje, ili neka od figura iste boje svojim kretanjem indirektno otvara mogucnos da taj kralj zavrsi u check poz
        var casultieTag: Int?
        var casultieName: String?
        var casultieColor: ColorOfTheChessPiece?
        var casultiePopulated = false
        // najpre proveravamo da li na odredisnom polju postoji figura koju treba privremeno izmestiti a sve u cilja izvodjenja simulacije i kasnijeg vracanja na prvobitno
        for field in fields {
            if field.fieldPositionValue == outputClass.fieldPositionValue {
                if field.fieldIsPopulated {
                    casultieTag = field.fieldCarriesPieceWithTag
                    casultieName = field.fieldCarriesPieceNamed
                    casultieColor = field.fieldCarriesPieceColor
                    casultiePopulated = true
                }
            }
        }
        // vrsimo manuelni upis u destination i brisanje iz origin, kao da se potez dogodio a sve radi realne simulacije
        for originField in fields {
            if originField.fieldPositionValue == inputClass.fieldPositionValue {
                for destinationField in fields {
                    if destinationField.fieldPositionValue == outputClass.fieldPositionValue {
                        destinationField.fieldCarriesPieceWithTag = originField.fieldCarriesPieceWithTag
                        destinationField.fieldCarriesPieceNamed = originField.fieldCarriesPieceNamed
                        destinationField.fieldCarriesPieceColor = originField.fieldCarriesPieceColor
                        destinationField.fieldIsPopulated = true
                        
                        originField.fieldCarriesPieceWithTag = nil
                        originField.fieldCarriesPieceNamed = nil
                        originField.fieldCarriesPieceColor = nil
                        originField.fieldIsPopulated = false
                        // zavrsavamo manuelni upis i brisanje, stanje za pocetak simulacije je sredjeno

        
                        for kingField in fields {
                            // posto se radi o klasama, izmena koju smo malnuelno izvrsili malopre, se preslikava, jer su klase BY REFERENCE i onda nam je kingField vac na destination fieldu ili ako nam je draze na outputClass
                            if kingField.fieldCarriesPieceColor == outputClass.fieldCarriesPieceColor {
                                if kingField.fieldIsPopulated {
                                    if abs(kingField.fieldCarriesPieceWithTag!) == 1040 {
                                        for opponentField in fields {
                                            if opponentField.fieldCarriesPieceColor != kingField.fieldCarriesPieceColor {
                                                if opponentField.fieldIsPopulated {
                                                    if MoveIsValid(originClass: opponentField, destinationClass: kingField, callerIsHuman: false, simulationCalling: false) {
                                                        //print("king on the field \(kingField.fieldPositionValue) would end up in danger from field \(opponentField.fieldPositionValue)")
                                                        // sada kad imamo rezultat simulacije, vracamo sve na prvobitno stanje
                                                        
                                                        
                                                        originField.fieldCarriesPieceWithTag = destinationField.fieldCarriesPieceWithTag
                                                        originField.fieldCarriesPieceNamed = destinationField.fieldCarriesPieceNamed
                                                        originField.fieldCarriesPieceColor = destinationField.fieldCarriesPieceColor
                                                        originField.fieldIsPopulated = true
                                                        
                                                        if casultiePopulated {
                                                            destinationField.fieldCarriesPieceWithTag = casultieTag
                                                            destinationField.fieldCarriesPieceNamed = casultieName
                                                            destinationField.fieldCarriesPieceColor = casultieColor
                                                            destinationField.fieldIsPopulated = true
                                                        } else {
                                                            destinationField.fieldCarriesPieceWithTag = nil
                                                            destinationField.fieldCarriesPieceNamed = nil
                                                            destinationField.fieldCarriesPieceColor = nil
                                                            destinationField.fieldIsPopulated = false
                                                        }
                                                        // zavrsavam vracanje na prvobitno stanje
                                                        return true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // sada kad imamo rezultat simulacije, vracamo sve na prvobitno stanje
                        originField.fieldCarriesPieceWithTag = destinationField.fieldCarriesPieceWithTag
                        originField.fieldCarriesPieceNamed = destinationField.fieldCarriesPieceNamed
                        originField.fieldCarriesPieceColor = destinationField.fieldCarriesPieceColor
                        originField.fieldIsPopulated = true
                        
                        if casultiePopulated {
                            destinationField.fieldCarriesPieceWithTag = casultieTag
                            destinationField.fieldCarriesPieceNamed = casultieName
                            destinationField.fieldCarriesPieceColor = casultieColor
                            destinationField.fieldIsPopulated = true
                        } else {
                            destinationField.fieldCarriesPieceWithTag = nil
                            destinationField.fieldCarriesPieceNamed = nil
                            destinationField.fieldCarriesPieceColor = nil
                            destinationField.fieldIsPopulated = false
                        }
                        // zavrsavam vracanje na prvobitno stanje
                    }
                }
            }
        }
        //print("king is FREE to proceed, not stepping into check position")
        return false
    }
    
    func KingInCheck() -> (inCheck: Bool, kingField: OneField?, opponentField: OneField?) {
        // func proverava da li je protivnicki kralj, npr beli, nakon izvrsenja nekog poteza npr crnih figura, zavrsio u check poziciji
        for opponentField in fields {
            if opponentField.fieldCarriesPieceColor == moves.last?.whichColorMoved {
                if opponentField.fieldIsPopulated {
                    for kingField in fields {
                        if kingField.fieldCarriesPieceColor != moves.last?.whichColorMoved {
                            if kingField.fieldIsPopulated {
                                if abs(kingField.fieldCarriesPieceWithTag!) == 1040 {
                                    if MoveIsValid(originClass: opponentField, destinationClass: kingField, callerIsHuman: false, simulationCalling: false) {
                                        //print("kralj koji se nalazi na \(kingField.fieldPositionValue) je u opasnosti od \(opponentField.fieldPositionValue)")
                                        

                                        
                                        
      
                                        
                                        return (true, kingField, opponentField)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        //print("protivnicki kralj ovim potezom nije dospeo u check poziciju")
        return (false, nil, nil)
    }
    
    func ShowPotentialFields(originClass: OneField) {
        //print("ShowPotentialFields")
        var funcWaitWasCalled = false
        var potentialFieldsIlumination = Set<Int>()
        
        
        // proverava i iluminira sva polja koja su moguca kao odrediste za kliknutu figuru i oznacava ih zelenom, a narandzastom ona na kojima moze biti casultie
        for opponentField in fields {
            if opponentField.fieldCarriesPieceColor != originClass.fieldCarriesPieceColor {
                if MoveIsValid(originClass: originClass, destinationClass: opponentField, callerIsHuman: false, simulationCalling: false) {
                    if validniUnosi.contains(opponentField.fieldName!) {
                        potentialFieldsIlumination.insert(opponentField.fieldPositionValue!)
                        opponentField.fieldIsIluminated = true
                        opponentField.fieldIluminationColor = UIColor.green
                        // narandzasta ukoliko je tu protivnicka figura
                        if opponentField.fieldIsPopulated {
                            opponentField.fieldIluminationColor = UIColor.orange
                        }

                        func Wait(seconds: Double){
                            //print("WAIT")
                            // aktivira tajmer da bi oznacena polja zelenom i narandzastom bojom imala efekat kratkog bljeska i deaktivira komplet user interaction
                            view.isUserInteractionEnabled = false
                            Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds),
                                                 repeats: false,
                                                 block: { (timer) in CleenUpPotentialFields()})
                        }
                        
                        func CleenUpPotentialFields() {
                            //print("CleenUpPotentialFields")
                            // func gasi iluminaciju na svim poljima koja su oznacena zelenom ili narandzastom u prethodnom koraku i updejtuje prikaz i aktivira user interact
                            for field in fields {
                                if potentialFieldsIlumination.contains(field.fieldPositionValue!) {
                                    field.fieldIsIluminated = false
                                }
                            }
                            view.isUserInteractionEnabled = true
                            //print("1335")
                            UpdateScreenForNewArrangment()
                        }
                        if !funcWaitWasCalled {
                            funcWaitWasCalled = true
                            Wait(seconds: 0.5)
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func Test(_ sender: Any) {
      //print(" test button")
        // dugme koje poziva Test funkciju
        Test()
    }
    
    @IBOutlet weak var cxLabel: UILabel!
    
    @IBOutlet weak var bestCBLabel: UILabel!
    
    @IBOutlet weak var worstCBlabel: UILabel!
    
    
    
    @IBOutlet weak var swAI: UISwitch!
    
    
    
    func Test() {
        
        
        
        
        //print(" test function")
        // izvrsava test elemente
        /*
         print(fields.count)
         for clan in fields {
         print(clan.fieldPositionValue, clan.fieldPositionX, clan.fieldPositionY, clan.fieldSize)
         print(clan.fieldName, clan.fieldColor, clan.fieldTitle, clan.userInteractionEnabled, clan.fieldIsIluminated, clan.fieldIluminationColor)
         print(clan.fieldCarriesPieceNamed, clan.fieldIsPopulated, clan.fieldCarriesPieceWithTag, clan.fieldCarriesPieceColor)
         }
         
         for clan in view.subviews {
         print(clan.tag)
         }
         
         DrawChessBoard()
         DrawChessPieces()
         
         print(moves.count)
         for move in moves {
         print(move.casulties, move.destinationHeldPiece)
         } */
        print("count SVIH mogucih simulacija ukljucujuci i onu prvu \(chessBoardSituations.count)")
        
        for situation in chessBoardSituations {
            print("\(situation.stepNumber) BranchID:: \(situation.branchID) AI:: \(situation.valueOfComputerPieces) USER:: \(situation.valueOfUserPieces) AI je od stabla do pupoljka ove grane izgubio ukuno poena:: \(situation.computerLosses), a USER ukupno poena:: \(situation.userLosses)")
            print("POTEZ JE BIO SLEDECI: \(situation.whatWasTheMove)")
            
            for field in situation.oneChessBoard {
                if field.fieldIsPopulated {
                    print(field.fieldName, field.fieldCarriesPieceNamed!)
                }
            }
            print("------------------")
        }
        
        var AImin: Float = 100_000_000
        var branchIDforAImin = ""
        var movesNeededForAImin = 100
        
        var AImax: Float = 0
        var branchIDforAImax = ""
        var movesNeededForAImax = 100
        
        var USERmin: Float = 100_000_000
        var branchIDforUSERmin = ""
        var movesNeededForUSERmin = 100
        
        var USERmax: Float = 0
        var branchIDforUSERmax = ""
        var movesNeededForUSERmax = 100
        
        // prvi korak - sortiramo da najpre budu navedene situacije gde user ima minimalnu vrednost figura
        func sortByMinimumValueOfUserPieces(s1: ChessBoard, s2: ChessBoard) -> Bool {
            return s1.valueOfUserPieces < s2.valueOfUserPieces
        }
        let chessBoardSituationsSORTEDbyMinValueOfUserPcs = chessBoardSituations.sorted(by: sortByMinimumValueOfUserPieces)

 
        // drugi korak - pravimo novi niz u koji ubacujemo samo situacije gde smo u bilo kojoj grani uspeli da chekiramo usera
        var chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCx = [ChessBoard]()
        for member in chessBoardSituationsSORTEDbyMinValueOfUserPcs {
            if member.valueOfUserPieces < 1000 {
                chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCx.append(member)
            }
        }
        
        // treci korak -  sortiramo tako da dobijemo niz koji na prvom mestu ima situacije koje dovode do chekiranja userovog kinga na najkraci nacin
        func sortByMinimumLenghtOfTheBranch(s1: ChessBoard, s2: ChessBoard) -> Bool {
            return s1.stepNumber < s2.stepNumber
        }
        let chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCxSortedByLengthOfBranch = chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCx.sorted(by: sortByMinimumLenghtOfTheBranch)
        
        
        
        print("SORTIRANO SORTIRANO SORTIRANO SORTIRANO")
        print("ukupno situacija koje mogu dovesti do sahiranja usera ima: \(chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCxSortedByLengthOfBranch.count) a sve sortirano po duzini poteza (najkraci je prvi)")
        for situation in chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCxSortedByLengthOfBranch {
            print("STEP: \(situation.stepNumber) BRANCH ident: \(situation.branchID) i vrednost USERa \(situation.valueOfUserPieces) i vredonost AIa \(situation.valueOfComputerPieces)")
            var branchesToShow = [String]()
            var spacesToSkip = situation.stepNumber * 2
            var skippedSpace = 0
            var stringToAdd = ""
            var didThis = 0
            
            repeat {
                didThis += 1
                for letter in situation.branchID.characters {
                    if letter == " " {
                        skippedSpace += 1
                    }
                        if skippedSpace <= spacesToSkip {
                            stringToAdd = stringToAdd + String(letter)
                        }
                }
                branchesToShow.append(stringToAdd)
                spacesToSkip -= 2
                skippedSpace = 0
                stringToAdd = ""
            } while didThis <= situation.stepNumber
            
            for i in 1...branchesToShow.count {
                print(branchesToShow[branchesToShow.count - i])
                for innerSituation in chessBoardSituations {
                    if innerSituation.branchID == branchesToShow[branchesToShow.count - i] {
                        print(innerSituation.whatWasTheMove)
                    }
                }
            }
            print("______________________________________________________________________")

        }
        
        var bestCBoption = ""
        var worstCBoption = ""
        
        print("UKOLIKO NEMA CHECK POZICIJE KOJA SE MOZE IZRACUNATI DAJEM OPCIJE KOJE U IZRACUNJIVOM OPSEGU DONOSE VECU KORIST NEGO STETU ZA AI")
        print("____________________________________________________________________________________________________________________________________________")
        
        func SortedByCostBenefitRatio(s1: ChessBoard, s2: ChessBoard) -> Bool {
            return s1.computerToUserSaldo < s2.computerToUserSaldo
        }
        let chessBoardSituationsSORTEDbyLowestCostHighestBenefitRATIOForComputer = chessBoardSituations.sorted(by: SortedByCostBenefitRatio)
        
        var counter = 0
        for situation in chessBoardSituationsSORTEDbyLowestCostHighestBenefitRATIOForComputer {
            counter += 1
            print("STEP: \(situation.stepNumber) BRANCH ident: \(situation.branchID) i vrednost USERa \(situation.valueOfUserPieces) i vredonost AIa \(situation.valueOfComputerPieces)")
            print("AI izgubio: \(situation.computerLosses), USER izgubio: \(situation.userLosses), COSST BENEFIT \(situation.computerToUserSaldo)  sve u PLUSU je beneficial za computer")
            var branchesToShow = [String]()
            var spacesToSkip = situation.stepNumber * 2
            var skippedSpace = 0
            var stringToAdd = ""
            var didThis = 0
            
            // ovde sad rasparcavam branchID, koji moze sadrzati samo jedan ali i vise koraka, tako da je svaki korak ponaosob i kao takvog ga apendujem u branchestoshow radi citljivijeg printa, jer se vidi sta je tacno bio i prvi i drugi i treci i .... korak
            repeat {
                didThis += 1
                for letter in situation.branchID.characters {
                    if letter == " " {
                        skippedSpace += 1
                    }
                    if skippedSpace <= spacesToSkip {
                        stringToAdd = stringToAdd + String(letter)
                    }
                }
                branchesToShow.append(stringToAdd)
                spacesToSkip -= 2
                skippedSpace = 0
                stringToAdd = ""
            } while didThis <= situation.stepNumber
            
            
           
            
            for i in 1...branchesToShow.count {
                print(branchesToShow[branchesToShow.count - i])
                for innerSituation in chessBoardSituations {
                    if innerSituation.branchID == branchesToShow[branchesToShow.count - i] {
                        print(innerSituation.whatWasTheMove)
                        
                        if counter == 1 {
                            worstCBoption += innerSituation.whatWasTheMove
                        } else if counter == chessBoardSituationsSORTEDbyLowestCostHighestBenefitRATIOForComputer.count - chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCxSortedByLengthOfBranch.count {
                            bestCBoption += innerSituation.whatWasTheMove
                        }
                    }
                }
            }
            print("___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___r___")
            
        }
        
        /*
        for situation in chessBoardSituations {
            if situation.valueOfComputerPieces < AImin && situation.stepNumber < movesNeededForAImin {
                AImin = situation.valueOfComputerPieces
                movesNeededForAImin = situation.stepNumber
                branchIDforAImin = situation.branchID
            } else if situation.valueOfComputerPieces > AImax && situation.stepNumber < movesNeededForAImax{
                AImax = situation.valueOfComputerPieces
                movesNeededForAImax = situation.stepNumber
                branchIDforAImax = situation.branchID
            } else if situation.valueOfUserPieces < USERmin && situation.stepNumber < movesNeededForUSERmin{
                USERmin = situation.valueOfUserPieces
                movesNeededForUSERmin = situation.stepNumber
                branchIDforUSERmin = situation.branchID
            } else if situation.valueOfUserPieces > USERmax && situation.stepNumber < movesNeededForUSERmax {
                USERmax = situation.valueOfUserPieces
                movesNeededForUSERmax = situation.stepNumber
                branchIDforUSERmax = situation.branchID
            }
        }
        */
        /*
        
         definisati sta je najbolja grana
         1. najbolja grana je ona koja sroza protivnika na sto manji value
         2. ako ih ima vise onda je najbolja ona koja taj najmanji value postize u najmanje koraka
         3.
 
        */
        
        //  simulate NE nastavlja sa razvojem grane u kojoj je bilo koji kralj sahiran. Ovo ne znaci da ta grana nece imati i druge simulacije (pupoljke) jer je mozda taj sah moguc i iz druge pozicije ali ce se tu prica za ovu granu zavrsiti, jer kad se uoci sah pozicija, grana se ne graana dalje vec se zavrsava kao pupoljak. Znaci da se nece stati sa celom granom na kojoj je uocen sah momentalno, vec ce nastaviti sa simulacijom tog dela grane kako bi pruzio sve moguce opcije koje proizilaze iz te tada bazne table ali naravno nece ekstendovati dalje tu granu jer ista donosi zadovoljavajuci rezultat, a to je stavljanje nekog kralja u sah. Treba znati i da simulacija krece sa stabla na tu prvu granu pa iz te prve tera u drugu trecu cetvrtu.... sve do pupoljka pa TEK KAD ZAVRSI SA PRVOM GRANOM IZ STABLA prelazi na drugu granu iz stabla pa sve do pupoljaka. postoji dobra mogucnost da ce tek ta druga grana iz stabla dati bolje resenje nekog poteza. Zato se prikazani minimumi i maksimumi odnose na one situacije u kojima ne vodimo racuna koliko je poteza potrebno da se do njih dodje vec je primarno da je vrednost figurica na tabli sto veca ili sto manja za datu boju figurica. Ovo cemo sad da resimo upotrebom stepnededfor....
        /*
        print("sekvenca u kojoj AI zavrsava sa MINIMALNO poena: \(branchIDforAImin) jer ce tako AI imati poena: \(AImin) sa najmanjim brojem koraka")
        print("sekvenca u kojoj AI zavrsava sa MAKSIMALNO poena: \(branchIDforAImax) jer ce tako AI imati poena: \(AImax) sa najmanjim brojem koraka")
        print("sekvenca u kojoj USER zavrsava sa MINIMALNO poena:  \(branchIDforUSERmin) jer ce tako USER imati poena: \(USERmin) sa najmanjim brojem koraka")
        print("sekvenca u kojoj USER zavrsava sa MAKSIMALNO poena: \(branchIDforUSERmax) jer ce tako USER imati poena: \(USERmax) sa najmanjim brojem koraka")
         */
        
        if moves.count == 0 {
            cxLabel.text == bestOpeningMove
            bestCBLabel.text = "videcemo kasnije"
            worstCBlabel.text = "ko ce ti ga znati"
        } else {
            if chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCxSortedByLengthOfBranch.count != 0 {
                cxLabel.text = "Najbolji potez koji vodi u najkraci izracunjivi Cx je " + (chessBoardSituationsSORTEDbyMinValueOfUserPcsJUSTCxSortedByLengthOfBranch.first?.whatWasTheMove)!
            } else {
                cxLabel.text = "Nema izracunjivog poteza koje vodi u Cx"
            }
            bestCBLabel.text = "Najbolja opcija ako nema izracunjivog Cx je " + bestCBoption
            worstCBlabel.text = "Najgora opcija je " + worstCBoption
        }
        
    }


    
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////// a.i. //////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    var whoAmI: ColorOfTheChessPiece?
    var whoIsMyOpponent: ColorOfTheChessPiece?
    
    var chessBoard = [ChessField]()
    var chessFields = [OneField]()

    struct ChessField {
        var fieldName: String
        var fieldPositionValue: Int
        var fieldIsPopulated = false
        var fieldCarriesPieceNamed: String?
        var fieldCarriesPieceWithTag: Int?
        var fieldCarriesPieceColor: ColorOfTheChessPiece?
    }
    
    struct ChessBoard {
        var whatWasTheMove = String()
        var stepNumber = Int()
        var branchID = String()
        var computerLosses = Float()
        var userLosses = Float()
        var computerToUserSaldo = Float()
        var userToComputerSaldo = Float()
        var oneChessBoard = [ChessField]()
        var valueOfComputerPieces = Float()
        var valueOfUserPieces = Float()
    }
    
    var chessBoardSituations = [ChessBoard]()
    
    func GetCurrentChessBoardSituation() {
        // puni niz koji zovemo chessBoard sa 64 strukture koje zovemo ChessField preslikavajuci tacnu trenutnu situaciju na tabli
        // u obzir se uzimaju samo polja od a1, a2, a3.... h6, h7, h8.
        chessBoard = []
        for field in fields {
            if validniUnosi.contains(field.fieldName!) {
                chessBoard.append(ChessField(fieldName: field.fieldName!,
                                           fieldPositionValue: field.fieldPositionValue!,
                                           fieldIsPopulated: field.fieldIsPopulated,
                                           fieldCarriesPieceNamed: field.fieldCarriesPieceNamed,
                                           fieldCarriesPieceWithTag: field.fieldCarriesPieceWithTag,
                                           fieldCarriesPieceColor: field.fieldCarriesPieceColor))
            }
        }
        chessBoardSituations.append(ChessBoard(whatWasTheMove: "no move",
                                               stepNumber: 0,
                                               branchID: "0",
                                               computerLosses: 0,
                                               userLosses: 0,
                                               computerToUserSaldo: 0,
                                               userToComputerSaldo: 0,
                                               oneChessBoard: chessBoard,
                                               valueOfComputerPieces: AssessTheValueOfOnePlayerOnTheBoard(whoToAssess: whoAmI!, oneBoard: chessBoard),
                                               valueOfUserPieces: AssessTheValueOfOnePlayerOnTheBoard(whoToAssess: whoIsMyOpponent!, oneBoard: chessBoard)))
    }
    var bestOpeningMove = ""
    func CheckIfItIsComputerTurn() {
        // proverava koja boja je prva nacinila potez i na osnovu toga dodeljuje kompjuteru slobodnu boju
        // ukoliko je poslednji potez nacinila boja koja je suprotna od boje dodeljenoj kompjuteru, poziva se AI func
        if moves.first?.whichColorMoved == ColorOfTheChessPiece.White {
            whoAmI = ColorOfTheChessPiece.Black
            whoIsMyOpponent = ColorOfTheChessPiece.White
        } else {
            whoAmI = ColorOfTheChessPiece.White
            whoIsMyOpponent = ColorOfTheChessPiece.Black
        }
        
        if moves.last?.whichColorMoved != whoAmI {
            print("na AI je red ukoliko nije bas prvi potez kompjutera, sada pozivam AI func")
            if moves.count == 1 {
                print("odgovoricu na klasican nacin")
                let userFirstMoveFiledValue = moves.first?.destinationFieldValue
                
                if moves.first?.originHeldPiece == "pesakBeli" {
                    if userFirstMoveFiledValue == 10104 {
                        bestOpeningMove = "Ware Opening, best move is e5"
                    } else if userFirstMoveFiledValue == 10103 {
                        bestOpeningMove = "Anderssen's Opening, best move is g6"
                    } else if userFirstMoveFiledValue == 10204 {
                        bestOpeningMove = ("Sokolsky Opening, best move is e6 ")
                    } else if userFirstMoveFiledValue == 10203 {
                        bestOpeningMove = ("Larsen's Opening, best move is e5")
                    } else if userFirstMoveFiledValue == 10304 {
                        bestOpeningMove = ("English Opening, best move is Nf6")
                    } else if userFirstMoveFiledValue == 10303 {
                        bestOpeningMove = ("Saragossa Opening, best move is d5")
                    } else if userFirstMoveFiledValue == 10404 {
                        bestOpeningMove = ("Queen's Pawn Opening, best move is Nf6")
                    } else if userFirstMoveFiledValue == 10403 {
                        bestOpeningMove = ("Mieses Opening, best move is d5")
                    } else if userFirstMoveFiledValue == 10504 {
                        bestOpeningMove = ("King's Pawn Opening, best move is c5")
                    } else if userFirstMoveFiledValue == 10503 {
                        bestOpeningMove = ("Van 't Kruijs Opening, best move is f5")
                    } else if userFirstMoveFiledValue == 10604 {
                        bestOpeningMove = ("Bird's Opening, best move is d5")
                    } else if userFirstMoveFiledValue == 10603 {
                        bestOpeningMove = ("Barnes Opening, best move is e5")
                    } else if userFirstMoveFiledValue == 10704 {
                        bestOpeningMove = ("Grob's Attack, best move is d5")
                    } else if userFirstMoveFiledValue == 10703 {
                        bestOpeningMove = ("Benko Opening, best move is d5")
                    } else if userFirstMoveFiledValue == 10804 {
                        bestOpeningMove = ("Desprez Opening, best move is d5")
                    } else if userFirstMoveFiledValue == 10803 {
                        bestOpeningMove = ("Clemenz Opening, best move is e5")
                    }
                } else {
                    // mora biti konj u pitanju
                    if userFirstMoveFiledValue == 10103 {
                        bestOpeningMove = ("Durkin Opening, best move is d5")
                    } else if userFirstMoveFiledValue == 10303 {
                        bestOpeningMove = ("Dunst Opening, best move is d5")
                    } else if userFirstMoveFiledValue == 10603 {
                        bestOpeningMove = ("Zukertort Opening, best move is Nf6")
                    } else if userFirstMoveFiledValue == 10803 {
                        bestOpeningMove = ("Ammonia Opening, best move is e5")
                    }
                }
            } else {
                AI()
            }
            
        } else {
            //chill while human thinks
            print("human")
        }
    }
    
    var whatStepToDo: Int = 0
    var specificBranchHasBeenSimulatedUpon = 0

    func AI() {
        whatStepToDo = 0
        chessBoardSituations = []
        GetCurrentChessBoardSituation()
        
        var whoIsBeingAttacked: ColorOfTheChessPiece
        var whoIsAttacking: ColorOfTheChessPiece
        
        // utvrdjujemo koliko ima figura na tabli radi uskladjivanja koliko koraka ai treba da simulira (0-1-2-3.. mozda 4-5 ako je bas malo figura na tabli)
        var howManyChessPiecesOnBoard = 0
        var howManyChessSimulationsShouldIDo = 0
        for field in chessBoard {
            if field.fieldIsPopulated {
                howManyChessPiecesOnBoard += 1
            }
        }
        
        if howManyChessPiecesOnBoard > 20 {
            howManyChessSimulationsShouldIDo = 1
        } else if howManyChessPiecesOnBoard >= 6 && howManyChessPiecesOnBoard <= 20 {
            howManyChessSimulationsShouldIDo = 1
        } else if howManyChessPiecesOnBoard == 4 || howManyChessPiecesOnBoard == 5 {
            howManyChessSimulationsShouldIDo = 1
        } else if howManyChessPiecesOnBoard < 4 {
            howManyChessSimulationsShouldIDo = 1
        }
        
        print("na osnovu broja figura na tabli kojih je trenutno \(howManyChessPiecesOnBoard) za vrednost howManyChessSimulationsShouldIDo postavljam sledece: \(howManyChessSimulationsShouldIDo)")
        
        // u repeat-while loop ulazimo veoma cisto, jer u pocetku imamo samo jednog clana u chessBoardSituations koji zapravo reprezentuje trenutno stanje na tabli od koga AI i polazi
        // sledi for petlja koja ce da izvrti svakog clana u chessboardsituations i da pogleda da li je stepnumber tog clana isti kao i whatsteptodo koji je na pocetku setovan na 0
        // prvi clan normalno prolazi jer je whatsteptodo sada nula a i prvi upis koji reprezentuje trenutno stanje table takodje notiran kao stepnumber nula
        // vodi se racuna na osnovu parnog neparnog sistema koju boju gadjamo kao target
        // ulazimo u simulate func u koju uguravamo pocetnu sahovsku tablu, informaciju koga gadjamo i broj kojim cemo notirati svaku narednu mogucu simulaciju stanja sahovske table
        // ovo znaci da ce ukoliko je korisnik povukao potez belom figurnom, svaki moguci prvi odgovor AI-ja biti notiran pod brojem 1
        // kada simulacija zavrsi prolaz u kome se svaki uspesan potez unosi kao i moguci vracamo se u for petlju koja sada opet gleda da li ima jos nekoga sa vrednoscu nula
        // kako nema, sto je i normalno jer je ovo bilo pocetno stanje FOR petlja iskace i sada PODIZEMO whatsteptoDo za jedan
        // na scenu stupa opet repet-while koji sad ima ovu vrednost koja iznosi JEDAN i opet ulazi u FOR petlju koja trazi sve clanove koji kao step number imaju JEDAN
        // njih je ovaj put dvadeset, pa pocinje sa svakim od njih ponaosob da ulazi u petlju Simulate gde novi mogucim potezima na osnovu simulacije koja nosi vrenost 1 daje oznaku 2
        // ovo sad malo duze traje jer mora da na osnovu dvadeset simulacija sa brojem jedan sada napravi za svaku od JEDINICA jos dvadeset DVOJKI
        // kad zavrsi sa nekom od JEDINICA func simulate iskace u FOR petlju ali joj FOR opet dobacuje neku novu JEDINICU i tako sve u krug dok ih ne predje sve
        // kada nema vise FOR petlja iskace, podize se whatsteptodo i proverava uslov za repeat-while koji je i jedini realni ogranicavajuci ovde
        // treba napomenuti da howManyChessSimulationsShouldIDo <= 1 daje sledece situacije: sta bi AI mogao da odigra sa svojim figurama, i sta bi korisnik mogao da odigra kao odgovor na AI-ov potez
        // povecavanjem na howManyChessSimulationsShouldIDo <= 2 dobijam i sta bi AI mogao da odgovori na takav korisnikov potez
        repeat {
            
            for member in chessBoardSituations {
                
                if member.stepNumber == whatStepToDo {

                    if (whatStepToDo / 2) * 2 == whatStepToDo {
                        //print("paran je \(whatStepToDo)")
                        whoIsBeingAttacked = whoIsMyOpponent!
                        whoIsAttacking = whoAmI!
                    } else {
                        //print("neparan je \(whatStepToDo)")
                        whoIsBeingAttacked = whoAmI!
                        whoIsAttacking = whoIsMyOpponent!
                    }
                    
                    //Simulate(oneChessBoardStruct: chessBoardSituations[whatStepToDo], whoIsBeingAttacked: whoIsBeingAttacked, stepNumber: member.stepNumber + 1)
                    specificBranchHasBeenSimulatedUpon = 0
                    
                    // poziva simulate samo za one grane u kojima ni jedan kralj nije u check poziciji
                    //if member.valueOfComputerPieces >= 1000 && member.valueOfUserPieces >= 1000 {
                    Simulate(oneChessBoardStruct: member, whoIsBeingAttacked: whoIsBeingAttacked, whoIsAttacking: whoIsAttacking, stepNumber: member.stepNumber + 1)
                    //}
                    
                    
                }
            }
            whatStepToDo += 1
            print("upravo sam podigao whatsteptodo na \(whatStepToDo)")

        } while whatStepToDo <= howManyChessSimulationsShouldIDo
        
        // nula daje jedan korak unapred (broj kombinacija 20)
        // kec daje dva koraka unapred (broj kombinacija 600) (oko 5 sekundi)
        // dvojka daje tri koraka unapred (broj kombinacija 15000) (ovo je sa dva minuta zadrske dok izracuna punu tablu bez optimizacije)
        // trojka daje cetiri koraka unapred (broj kombinacija 500.000) (oko 60 minuta)
        
        
        // mogucnosti su sledece, ako kucas howManyChessSimulationsShouldIDo i das mu vrednost <= 1 dobices kao rezultat sledece numeracije kao stepNumber:
        // IZRACUNAVA 8000 SIMULACIJA NA MINUT
        /*
 
         pod step numeber 0 dobijas trenutno stanje
         pod step number 1 dobijas sta bi kompjuter mogao da odigra
         pod step number 2 dobijas sta bi user mogao da odigra kao odgovor na step number 1
         
         suma sumarum dobijas jedan KOMPLETAN potez ( znaci jednom kompjuter, pa jednom user)
 
        */

    }
    
    func Simulate(oneChessBoardStruct: ChessBoard, whoIsBeingAttacked: ColorOfTheChessPiece, whoIsAttacking: ColorOfTheChessPiece, stepNumber: Int) {
        print("SIM: tren. count sim. je \(chessBoardSituations.count) baziram dalju sim. na baznoj simulaciji koja nosi broj \(oneChessBoardStruct.stepNumber) a onoj koju simulisem dodeljujem broj \(stepNumber)")
        
        var oneChessBoardConverted = Converter(oneBoard: oneChessBoardStruct.oneChessBoard)  // jer se mora zanoviti definisati bazna tabla - ovde hvatas onih prvih 20tak mogucih tabli u kojima potez pravi crni
        
        for destinationField in oneChessBoardConverted {
            if !destinationField.fieldIsPopulated || (destinationField.fieldIsPopulated && destinationField.fieldCarriesPieceColor == whoIsBeingAttacked) {
                for originField in oneChessBoardConverted {  // ovde hvatas prvi put pesaka belog sa a2
                    if originField.fieldIsPopulated && originField.fieldCarriesPieceColor != whoIsBeingAttacked {
                        if MoveIsValid(originClass: originField, destinationClass: destinationField, callerIsHuman: false, simulationCalling: true) {
                            /*
                            print("jeste, prosao je potez \(originField.fieldCarriesPieceNamed) sa \(originField.fieldName) na polje \(destinationField.fieldName)")
                            
                            print("ajde prvo stampam kako izgleda baza na osnovu koje JE PROSAO potez:")
                            for field in oneChessBoardConverted {
                                if field.fieldIsPopulated {
                                    print(field.fieldName, field.fieldCarriesPieceNamed)
                                }
                            }
                            
                            */
                            
                            var nextChessBoard = oneChessBoardStruct.oneChessBoard  // ovde hvatas kopiju table na kojoj ces samo da izmenis ono sto je potez belog pesaka sa a2 na a4
                            specificBranchHasBeenSimulatedUpon += 1
                            var whatWasTheMove = ""
                            whatWasTheMove = "sa polja " + originField.fieldName! + " figuru " + originField.fieldCarriesPieceNamed! + " premestam na polje " + destinationField.fieldName!
                            if destinationField.fieldIsPopulated {
                                whatWasTheMove = whatWasTheMove + " na kome je stradala sledeca figura \(destinationField.fieldCarriesPieceNamed!)"
                            } else {
                                whatWasTheMove += " na kom nije bilo protivnicke figure"
                            }
                            //print("specific branch ident krajnji je \(specificBranchHasBeenSimulatedUpon)")
                            
                            for j in 0...nextChessBoard.count - 1 {
                                if nextChessBoard[j].fieldPositionValue == destinationField.fieldPositionValue {  // ovde direktno upisujes pesaka na a4
                                    nextChessBoard[j].fieldIsPopulated = true
                                    nextChessBoard[j].fieldCarriesPieceWithTag = originField.fieldCarriesPieceWithTag
                                    nextChessBoard[j].fieldCarriesPieceNamed = originField.fieldCarriesPieceNamed
                                    nextChessBoard[j].fieldCarriesPieceColor = originField.fieldCarriesPieceColor
                                }
                            }
                            
                            for j in 0...nextChessBoard.count - 1 {  // ovde direktno brises pesaka sa a2
                                if nextChessBoard[j].fieldPositionValue == originField.fieldPositionValue {
                                    nextChessBoard[j].fieldIsPopulated = false
                                    nextChessBoard[j].fieldCarriesPieceWithTag = nil
                                    nextChessBoard[j].fieldCarriesPieceNamed = nil
                                    nextChessBoard[j].fieldCarriesPieceColor = nil
                                }
                            }
                            
                            /*
                            print("sada kada sam napravio izmenu koja ce da nosi broj od specific brancha \(specificBranchHasBeenSimulatedUpon) da proverimo jos jednom kako ovo sve izgleda")
                            
                            print("sad stampam kako izgleda next chess board:")
                            for field in nextChessBoard {
                                if field.fieldIsPopulated {
                                    print(field.fieldName, field.fieldCarriesPieceNamed)
                                }
                            }
                            */
                            
                            // sada imas u nextchessboard pesaka na a4 i prazno mesto na a2
                            
                            
                            //print("apendujem jednu TABLU IAKO PRIKAZUJEM SAMO ONO STO APENDUJEM jer je prosla move is valid i dodeljujem joj  sledeci stepnumber \(stepNumber, originField.fieldName!, originField.fieldCarriesPieceNamed!, destinationField.fieldName!)")
                            

                            var valueOfComputerPieces = AssessTheValueOfOnePlayerOnTheBoard(whoToAssess: whoAmI!,oneBoard: nextChessBoard)
                            var valueOfUserPieces = AssessTheValueOfOnePlayerOnTheBoard(whoToAssess: whoIsMyOpponent!,oneBoard: nextChessBoard)
                           

                            
                            let computerLosses = (chessBoardSituations.first?.valueOfComputerPieces)! - valueOfComputerPieces
                            let userLosses = (chessBoardSituations.first?.valueOfUserPieces)! - valueOfUserPieces
                            
                            chessBoardSituations.append(ChessBoard(whatWasTheMove: whatWasTheMove, stepNumber: stepNumber,
                                                                   branchID: oneChessBoardStruct.branchID + " - " + String(stepNumber) + "." + String(specificBranchHasBeenSimulatedUpon),
                                                                  
                                                                   computerLosses: computerLosses,
                                                                   userLosses: userLosses,
                                                       
                                                                   computerToUserSaldo: userLosses -  computerLosses,
                                                                   userToComputerSaldo: computerLosses - userLosses,
                                                                   
                                                                   oneChessBoard: nextChessBoard,
                                                                   valueOfComputerPieces: valueOfComputerPieces,
                                                                   valueOfUserPieces: valueOfUserPieces))
                            
                            // OVDE BI TREBALO IZVRSITI PROVERU CELE TABLE DA LI TABLA KAO REZULTAT IMA ULAZAK U CHECK (BILO AKTIVNIM - BILO PASIVNIM) U ODNOSU NA ONOG KOJI POMERA FIGURU (ZNACI AKO TAJ KOJI PRAVI POTEZ KAO REZULTAT IMA DA NJEGOV KRALJ OSTANE U CHECKU....) I AKO JE TAKO OBRISATI CELU TABLU
                            // onaj koji vrsi upis kao povlacioc poslednjeg poteza ima drugaciju boju od whoisbeing attacked
                            /*
                            let whoToAssess: ColorOfTheChessPiece
                            if whoIsBeingAttacked == whoAmI {
                                whoToAssess = whoIsMyOpponent!
                            } else {
                                whoToAssess = whoAmI!
                            }
                            
                            if inCheck(checkingIfThisKingIsInDanger: whoAmI!, oneBoard: nextChessBoard) {
                                print("BINGO")
                                chessBoardSituations.removeLast()
                            }
                            
                            if inCheck(checkingIfThisKingIsInDanger: whoIsMyOpponent!, oneBoard: nextChessBoard) {
                                print("BINGO")
                                chessBoardSituations.removeLast()
                            }
                            */
                            
                            // ovde proveravamo da li je king onoga ko vuce potez iz simulacije kojim slucajem stupio u check poziciju sa svojim kraljem, bilo pasivno
                            // ovo radimo nakon povlacenja poteza, i ako se pokaze da je taj potez onoga koji je potez povukao doveo u situaciju da je njegov king stupio potezom u self-check removujemo takvu tablu jer je potez nevalidan
                for opponentField in Converter(oneBoard: (chessBoardSituations.last?.oneChessBoard)!) {
                                if opponentField.fieldIsPopulated && opponentField.fieldCarriesPieceColor != whoIsAttacking {
                                    for kingField in Converter(oneBoard: (chessBoardSituations.last?.oneChessBoard)!) {
                                        if kingField.fieldIsPopulated && kingField.fieldCarriesPieceColor == whoIsAttacking {
                                            if abs(kingField.fieldCarriesPieceWithTag!) == 1040 {
                                               
                                                //print("probam za \(opponentField.fieldName) na king field \(kingField.fieldName)")
                                                
                                                for member in (chessBoardSituations.last?.oneChessBoard)! {
                                                    //print(member.fieldCarriesPieceWithTag)
                                                    if member.fieldIsPopulated {
                                                        //print(member.fieldName, member.fieldCarriesPieceNamed, member.fieldCarriesPieceWithTag)
                                                    }
                                                }
                                                
                                                if MoveIsValid(originClass: opponentField, destinationClass: kingField, callerIsHuman: false, simulationCalling: true) {
                                                    chessBoardSituations.removeLast()
                                                    //print("removujem last")
                                                    // SMANJITI COUNTER SPECIFICBRANCH!!!!!!!!
                                                    specificBranchHasBeenSimulatedUpon -= 1
                                                }
                                            }
                                        }
                                    }
                                }
                            }
          
                            /* stampa sve kombinacije
                            print(chessBoardSituations.last?.stepNumber, chessBoardSituations.last?.valueOfComputerPieces, chessBoardSituations.last?.valueOfUserPieces)
                            for field in (chessBoardSituations.last?.oneChessBoard)! {
                                if field.fieldIsPopulated {
                                    print(field.fieldName, field.fieldCarriesPieceNamed ?? "PRAZNO")
                                }
                            }*/
                        }
                        oneChessBoardConverted = Converter(oneBoard: oneChessBoardStruct.oneChessBoard) // jer se mora zanoviti chessFields da valjaju kad je move is valid
                    }
                }
                oneChessBoardConverted = Converter(oneBoard: oneChessBoardStruct.oneChessBoard) // jer se mora zanoviti chessFields da valjaju kad menja origin
            }
        }
        oneChessBoardConverted = Converter(oneBoard: oneChessBoardStruct.oneChessBoard) // jer se mora zanoviti chessFields da valjaju kad menja destination
        print("specific branch ident krajnji je \(specificBranchHasBeenSimulatedUpon)")

        
                /*
        for situation in chessBoardSituations {
            // stampa samo situacije u kojima je u odnosu na pocetno stanje kompjuter u stanju da napravi neki pomak u odnosu snaga u korist kompjutera
            if situation.valueOfComputerPieces / situation.valueOfUserPieces > (chessBoardSituations.first?.valueOfComputerPieces)! / (chessBoardSituations.first?.valueOfUserPieces)! {
                print(situation.valueOfComputerPieces, situation.valueOfUserPieces, situation.valueOfComputerPieces / situation.valueOfUserPieces)
                for field in situation.oneChessBoard {
                    if field.fieldIsPopulated {
                        print(field.fieldCarriesPieceNamed, field.fieldName)
                    }
                }
            }
        } */
    }
  
    func inCheck(checkingIfThisKingIsInDanger: ColorOfTheChessPiece, oneBoard: [ChessField]) -> Bool {
        // func kao input uzima jednu sahovsku tablu kao niz struktura ChessField, poziva konverzionu func i vraca Bool
        // dobija niz ChessFieldova koji predstavljaju jednu tablu i proveravam da li je computerKing inCheck i vracam bool
        let oneBoardClass = Converter(oneBoard: oneBoard) // mora se prebaciti iz struct u klasu jer ceo mehanizam validacije poteza ocekuje klasu kao input
        
        for userField in oneBoardClass {
            if userField.fieldCarriesPieceColor != checkingIfThisKingIsInDanger {
                if userField.fieldIsPopulated {
                    for kingField in oneBoardClass {
                        if kingField.fieldCarriesPieceColor == checkingIfThisKingIsInDanger && kingField.fieldIsPopulated {
                            if abs(kingField.fieldCarriesPieceWithTag!) == 1040 {
                                if MoveIsValid(originClass: userField, destinationClass: kingField, callerIsHuman: false, simulationCalling: true) {
                                    //print("prosao 1649 gde se sa polja \(userField.fieldName) gadja \(kingField.fieldName)")
                                    return true
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    

    
    func Converter(oneBoard: [ChessField]) -> [OneField] {
        // konvertuje niz sahovskih polja koji su strukture u niz identicnih sahovskih polja koji su sada reprezentovani kroz klase
        chessFields = []
        //print("praznim niz chessFields od svih clanova koji su niz klasa OneField")
        for board in oneBoard {
            if board.fieldIsPopulated {
                chessFields.append(OneField(fieldName: board.fieldName,
                                            fieldPositionValue: board.fieldPositionValue,
                                            fieldIsPopulated: board.fieldIsPopulated,
                                            fieldCarriesPieceNamed: board.fieldCarriesPieceNamed,
                                            fieldCarriesPieceWithTag: board.fieldCarriesPieceWithTag,
                                            fieldCarriesPieceColor: board.fieldCarriesPieceColor))
            } else {
                chessFields.append(OneField(fieldName: board.fieldName,
                                            fieldPositionValue: board.fieldPositionValue,
                                            fieldIsPopulated: false,
                                            fieldCarriesPieceNamed: nil,
                                            fieldCarriesPieceWithTag: nil,
                                            fieldCarriesPieceColor: nil))
            }
        }
        //print("napunio sam niz chessFields sa novim sadrzajem")
        return chessFields
    }
    
    func AssessTheValueOfOnePlayerOnTheBoard(whoToAssess: ColorOfTheChessPiece, oneBoard: [ChessField]) -> Float {
        var valueOfOnePlayer: Float = 0.0
        for field in oneBoard {
            if field.fieldIsPopulated {
                if field.fieldCarriesPieceColor == whoToAssess {
                    if abs(field.fieldCarriesPieceWithTag!) >= 2010 && abs(field.fieldCarriesPieceWithTag!) <= 2090 { // pawn
                        valueOfOnePlayer += 1
                    } else if abs(field.fieldCarriesPieceWithTag!) >= 1010 && abs(field.fieldCarriesPieceWithTag!) < 1020 ||
                        abs(field.fieldCarriesPieceWithTag!) >= 1080 && abs(field.fieldCarriesPieceWithTag!) < 1090 { // rook
                        valueOfOnePlayer += 6
                    } else if abs(field.fieldCarriesPieceWithTag!) >= 1020 && abs(field.fieldCarriesPieceWithTag!) < 1030 ||
                        abs(field.fieldCarriesPieceWithTag!) >= 1070 && abs(field.fieldCarriesPieceWithTag!) < 1080 { // knight
                        valueOfOnePlayer += 2
                    } else if abs(field.fieldCarriesPieceWithTag!) >= 1030 && abs(field.fieldCarriesPieceWithTag!) < 1040 ||
                        abs(field.fieldCarriesPieceWithTag!) >= 1060 && abs(field.fieldCarriesPieceWithTag!) < 1070 { // bishop
                        valueOfOnePlayer += 4
                    } else if abs(field.fieldCarriesPieceWithTag!) >= 1050 && abs(field.fieldCarriesPieceWithTag!) < 1060 { // queen
                        valueOfOnePlayer += 10
                    } else if abs(field.fieldCarriesPieceWithTag!) == 1040 { // KING
                        valueOfOnePlayer += 1000
                    }
                }
            }
        }
        
        // sada proveravamo da li je kralj onoga koga proveravamo kojim slucajem u check poziciju
        if inCheck(checkingIfThisKingIsInDanger: whoToAssess, oneBoard: oneBoard) {
            valueOfOnePlayer -= 1000
        }
 
        return valueOfOnePlayer
    }
    
}

// treba svaki put utvrditi ishod tvog poteza kroz odnos onoga sto si izgubio i onoga sto si dobio. mora se gledati risk benefit da se figura ne bi zrtvovala bezrazlozno. znaci obavezno obratiti paznju na taj deo.... a to mozes samo kroz value tvojih i protivnickih figura
