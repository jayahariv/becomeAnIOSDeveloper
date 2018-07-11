//
/*
CIAddressTypeahead.swift
Created on: 7/5/18

Abstract:
 address typeahead.

*/

import UIKit
import MapKit

/**
 delegate to receive the results array when address typeahead is populated
 */
@objc protocol CIAddressTypeaheadProtocol {
    func didSelectAddress(localSearch: MKLocalSearchCompletion)
}

final class CIAddressTypeahead: UITextField {
    
    // MARK: Properties
    
    /// set this to receive the new results of array when user types in the textfield.
    @IBOutlet var typeaheadDelegate: CIAddressTypeaheadProtocol?
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var resultsTable: UITableView!
    private var results = [MKLocalSearchCompletion]()
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        resultsTable = UITableView(coder: aDecoder)
        delegate = self
        searchCompleter.delegate = self
        addResultsTable()
    }
    
    override func layoutSubviews() {
        resultsTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.centerX,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: self,
                           attribute: NSLayoutAttribute.centerX,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.top,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: self,
                           attribute: NSLayoutAttribute.bottom,
                           multiplier: 1,
                           constant: 12).isActive = true
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.width,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute,
                           multiplier: 1,
                           constant: frame.size.width).isActive = true
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.height,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute,
                           multiplier: 1,
                           constant: 176).isActive = true
    }
    
    // MARK: Helper methods
    
    func addResultsTable() {
        addSubview(resultsTable)
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.isHidden = true
    }
    
    /**
     captures the touches in the tableview which is overflown from textfield
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return self
    }
}

// MARK: CIAddressTypeahead -> UITextFieldDelegate

extension CIAddressTypeahead: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        // only search after 3rd character
        guard let previousText = textField.text, previousText.count > 3 else {
            resultsTable.isHidden = true
            return true
        }
        
        let newString = previousText.replacingCharacters(in: Range(range, in: previousText)!, with: string)
        searchCompleter.queryFragment = newString
        
        return true
    }
}

extension CIAddressTypeahead: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        resultsTable.isHidden = results.count == 0
        resultsTable.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension CIAddressTypeahead: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        let result = results[indexPath.row]
        cell?.textLabel?.text = result.title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        typeaheadDelegate?.didSelectAddress(localSearch: results[indexPath.row])
    }
}
