//
//  TodoItemTest.swift
//  YaToDoListTests
//
//  Created by Екатерина Вишневская on 16.06.2023.
//

import XCTest
@testable import YaToDoList

class TodoItemTest: XCTestCase {

    var dateFormatter: DateFormatter?
    
    override func setUp() {
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }

    override func tearDown() {
        dateFormatter = nil
    }

    func test_csv() {
        let item = TodoItem(text: "Test", importance: .normal, done: false)
        let item2 = TodoItem.parse(csv: item.csv)
        XCTAssert(item2 != nil)
        guard let item2 = item2 else {
            return
        }
        areItemsEqual(item1: item, item2: item2)
        
    }
    
    func test_csv2() {
        let item = TodoItem(id: "A", text: "Test", importance: .important, deadline: Date().addingTimeInterval(1000), done: true, creationDate: Date(), changeDate: Date().addingTimeInterval(100))
        let item2 = TodoItem.parse(csv: item.csv)
        XCTAssert(item2 != nil)
        guard let item2 = item2 else {
            return
        }
        areItemsEqual(item1: item, item2: item2)
        
    }
    
    func test_json() {
        let item = TodoItem(text: "Test", importance: .normal, done: false)
        let item2 = TodoItem.parse(json: item.json)
        XCTAssert(item2 != nil)
        guard let item2 = item2 else {
            return
        }
        areItemsEqual(item1: item, item2: item2)
        
    }
    
    func test_json2() {
        let item = TodoItem(id: "A", text: "Test", importance: .important, deadline: Date().addingTimeInterval(1000), done: true, creationDate: Date(), changeDate: Date().addingTimeInterval(100))
        let item2 = TodoItem.parse(json: item.json)
        XCTAssert(item2 != nil)
        guard let item2 = item2 else {
            return
        }
        areItemsEqual(item1: item, item2: item2)
        
    }
    
    func test_FileCacheAdd() {
        let fileCache = FileCache()
        let item = TodoItem(text: "Test", importance: .normal, done: false)
        fileCache.add(item: item)
        XCTAssert(fileCache.todoList.count == 1)
    }
    
    func test_FileCacheDeleteExisted() {
        let fileCache = FileCache()
        let item = TodoItem(id: "a", text: "Test", importance: .normal, done: false)
        fileCache.add(item: item)
        fileCache.delete(id: "a")
        XCTAssert(fileCache.todoList.isEmpty)
    }
    
    func test_FileCacheDeleteNotExisted() {
        let fileCache = FileCache()
        let item = TodoItem(id: "a", text: "Test", importance: .normal, done: false)
        fileCache.add(item: item)
        fileCache.delete(id: "b")
        XCTAssert(fileCache.todoList.count == 1)
    }

    private func areItemsEqual(item1:TodoItem, item2:TodoItem) {
        XCTAssertEqual(item1.id, item2.id)
        XCTAssertEqual(item1.text, item2.text)
        XCTAssertEqual(item1.importance, item2.importance)
        XCTAssert((item1.deadline == nil) == (item2.deadline == nil))
        if let date1 = item1.deadline, let date2 = item2.deadline {
            XCTAssertEqual(Int(date1.timeIntervalSince1970), Int(date2.timeIntervalSince1970))
        }
        XCTAssertEqual(item1.done, item2.done)
        XCTAssertEqual(Int(item1.creationDate.timeIntervalSince1970), Int(item2.creationDate.timeIntervalSince1970))
        XCTAssert((item1.changeDate == nil) == (item2.changeDate == nil))
        if let date1 = item1.changeDate, let date2 = item2.changeDate {
            XCTAssertEqual(Int(date1.timeIntervalSince1970), Int(date2.timeIntervalSince1970))
        }
    }
}
