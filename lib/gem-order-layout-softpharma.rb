require 'date'
require 'net/ftp'

module OrderLayoutSoftPharma

  $ftp_url = ''
  $ftp_port = 0
  $ftp_user = ''
  $ftp_password = ''
  $ftp_passive = false
  $codClient = 0
  $numOrder = 0
  $clientCnpjOrder = 0
  $currentUserName = ''
  $establishmentCnpj = 0
  $comment = ''
  $marketingPolicyId = 0
  $deadlineId = 0

  def self.set_connect ftp_url, ftp_port
    $ftp_url = ftp_url  #Rails.application.config.ftp_url
    $ftp_port = ftp_port #Rails.application.config.ftp_port
  end

  def self.set_login user, password
    $ftp_user = user #Rails.application.config.ftp_user
    $ftp_password = password #ails.application.config.ftp_password
  end

  def self.set_ftp_passive isPassive
    $ftp_passive = isPassive # Rails.application.config.ftp_passive
  end

  def self.set_establishmentCnpj establishmentCnpj
    $establishmentCnpj = establishmentCnpj
  end

  def self.set_codClient codClient
    $codClient = codClient
  end

  def self.set_numOrder numOrder
    $numOrder = numOrder
  end

  def self.set_clientCnpjOrder clientCnpjOrder
    $clientCnpjOrder = clientCnpjOrder
  end

  def self.set_currentUserName currentUserName
    $currentUserName = currentUserName
  end

  def self.set_comment comment
    $comment = comment
  end

  def self.set_marketingPolicyId marketingPolicyId
    $marketingPolicyId = marketingPolicyId
  end

  def self.set_deadlineId deadlineId
    $deadlineId = deadlineId
  end

  def self.set_totalOrders totalOrders
    $totalOrders = totalOrders
  end

  def self.set_totalUnits totalUnits
    $totalUnits = totalUnits
  end

  #===========================
  #=cria pasta, se não existir
  #===========================
  def self.create_folder directory_name
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
  end

  #=============================================
  #=Envia pedido via FTP para Pedido Eletrônico
  #=============================================
  def self.send_ftp directory_name

    # new(host = nil, user = nil, passwd = nil, acct = nil)
    # Creates and returns a new FTP object. If a host is given, a connection is made.
    # Additionally, if the user is given, the given user name, password, and (optionally) account are used to log in.
    ftp = Net::FTP.new(false)

    # connect(host, port = FTP_PORT)
    # Establishes an FTP connection to host, optionally overriding the default port.
    ftp.connect($ftp_url, $ftp_port)

    # login(user = "anonymous", passwd = nil, acct = nil)
    # string “anonymous” and the password is nil, a password of user@host is synthesized.
    # If the acct parameter is not nil, an FTP ACCT command is sent following the successful login.
    #ftp.login(Rails.application.config.ftp_user, Rails.application.config.ftp_password)
    ftp.login($ftp_user, $ftp_password)

    #When true, the connection is in passive mode. Default: false.
    #ftp.passive = Rails.application.config.ftp_passive
    ftp.passive = $ftp_passive

    #Changes the (remote) directory.
    ftp.chdir('/ped')

    ftp.put(directory_name)
    ftp.close

  end

  #========================
  #= Ler arquivo de pedido
  #========================
  def self.read_order txt
    header = {}
    details = []
    trailer = {}

    txt.each_line do |line|
      if line[0] == '1' # Header
        header = {
          register_type: line[0],
          client_code: line[1...7],
          cnpj_client: line[7...21],
          order_number: line[21...33],
          order_date: line[33...41],
          reserved: line[41...71]
        }
      elsif line[0] == '2' # Itens
        details << {
          register_type: line[0],
          product_code: line[1...15],
          quantity: line[15...20],
          price: line[20...32],
          offer_code: line[32...37],
          offer_time: line[37...40],
          reserved: line[40...70]
        }
      else # Trailer
        trailer = {
          register_type: line[0],
          order_number: line[1...13],
          number_of_items: line[13...18],
          number_of_units: line[18...28],
          order_number_complement: line[28...31],
          reserved: line[31...80]
        }
      end
    end

    { header: header, details: details, trailer: trailer }
  end

  #=========================
  #= Ler arquivo de retorno
  #=========================
  def self.read_return txt
    header = {}
    details = []
    trailer = {}

    txt.each_line do |line|
      if line[0] == '1' # Header
        header = {
            register_type: line[0],
            client_code: line[1...7],
            cnpj_client: line[7...21],
            order_number: line[21...33],
            order_date: line[33...41],
            order_processing_hour: line[41...49],
            order_situation: line[49...51],
            reserved: line[51...81]
        }
      elsif line[0] == '2' # Detalhe
        details << {
            register_type: line[0],
            product_code: line[1...15],
            number_served: line[15...20],
            number_not_served: line[20...25],
            reason_description: line[25...27],
            reserved: line[27...57]
        }
      else # Trailer
        trailer = {
            register_type: line[0],
            order_number: line[1...13],
            number_items: line[13...18],
            number_served_items: line[18...23],
            number_not_served_items: line[23...28],
            reserved: line[28...58]
        }
      end
    end

    { header: header, details: details, trailer: trailer }
  end
end
