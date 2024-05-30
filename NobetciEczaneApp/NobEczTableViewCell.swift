import UIKit

class NobEczTableViewCell: UITableViewCell {
    @IBOutlet weak var eczAdiLabel: UILabel!
    @IBOutlet weak var EczUzaklikLabel: UILabel!
    @IBOutlet weak var EczSemtLabel: UILabel!
    @IBOutlet weak var EczAdresLabel: UILabel!
    @IBOutlet weak var EczTelLabel: UILabel!
    
    @IBOutlet weak var araButton: UIButton!
    @IBOutlet weak var yolTarifiButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
